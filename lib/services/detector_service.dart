import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Rect, Size;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/detection.dart';

/// On-device YOLO litter detector with proper Letterbox preprocessing
/// (zero aspect-ratio distortion) and adaptive sensitivity for indoor & outdoor objects.
class DetectorService {
  static final DetectorService instance = DetectorService._internal();
  DetectorService._internal();

  static const int _inputSize = 640;
  // Lowered threshold from 0.30 to 0.18 to reliably catch indoor paper, cups, and litter
  static const double _confThreshold = 0.18;
  static const double _iouThreshold = 0.45;
  static const int _maxDetections = 20;

  Interpreter? _interpreter;
  String? loadError;

  bool get isReady => _interpreter != null;

  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/trash_detector.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      final i = _interpreter!.getInputTensors().first.shape;
      final o = _interpreter!.getOutputTensors().first.shape;
      debugPrint('Model loaded. input=$i output=$o');
    } catch (e) {
      loadError = '$e';
      debugPrint('Model failed to load: $e');
    }
  }

  Future<ScanResult> scan(File file) async {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('Detection model is not loaded. ${loadError ?? ''}');
    }

    await Future<void>.delayed(const Duration(milliseconds: 60));

    final decoded = img.decodeImage(await file.readAsBytes());
    if (decoded == null) throw StateError('Could not read that image.');
    final oriented = img.bakeOrientation(decoded);
    final imageSize =
        Size(oriented.width.toDouble(), oriented.height.toDouble());

    final origW = oriented.width.toDouble();
    final origH = oriented.height.toDouble();

    // Standard YOLO Letterbox: preserve exact aspect ratio without squashing!
    final scale = math.min(_inputSize / origW, _inputSize / origH);
    final newW = (origW * scale).round();
    final newH = (origH * scale).round();
    final padX = (_inputSize - newW) / 2.0;
    final padY = (_inputSize - newH) / 2.0;

    final canvas = img.Image(width: _inputSize, height: _inputSize);
    img.fill(canvas, color: img.ColorRgb8(114, 114, 114)); // Standard YOLO 114 gray pad

    final scaled = img.copyResize(
      oriented,
      width: newW,
      height: newH,
      interpolation: img.Interpolation.linear,
    );
    img.compositeImage(
      canvas,
      scaled,
      dstX: padX.round(),
      dstY: padY.round(),
    );

    final inShape = interpreter.getInputTensors().first.shape;
    final channelsFirst = inShape.length == 4 && inShape[1] == 3;

    final plane = _inputSize * _inputSize;
    final data = Float32List(plane * 3);
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final p = canvas.getPixel(x, y);
        final idx = y * _inputSize + x;
        final r = p.r / 255.0;
        final g = p.g / 255.0;
        final b = p.b / 255.0;
        if (channelsFirst) {
          data[idx] = r.toDouble();
          data[plane + idx] = g.toDouble();
          data[2 * plane + idx] = b.toDouble();
        } else {
          data[idx * 3] = r.toDouble();
          data[idx * 3 + 1] = g.toDouble();
          data[idx * 3 + 2] = b.toDouble();
        }
      }
    }

    final outShape = interpreter.getOutputTensors().first.shape;
    final total = outShape.reduce((a, b) => a * b);
    final output = List.filled(total, 0.0).reshape(outShape);

    interpreter.run(data.buffer.asUint8List(), output);

    final rawDetections = _decode(
      output[0] as List,
      outShape,
      padX: padX,
      padY: padY,
      newW: newW.toDouble(),
      newH: newH.toDouble(),
    );

    // Extract visual features for robust tracking across frames
    final enriched = rawDetections.map((d) {
      final features = _extractVisualFeatures(oriented, d.box);
      return DetectedObject(
        box: d.box,
        confidence: d.confidence,
        visualFeatures: features,
      );
    }).toList();

    return ScanResult(detections: enriched, imageSize: imageSize);
  }

  static List<double> _extractVisualFeatures(img.Image image, Rect box) {
    final x0 = (box.left * image.width).toInt().clamp(0, image.width - 1);
    final y0 = (box.top * image.height).toInt().clamp(0, image.height - 1);
    final x1 = (box.right * image.width).toInt().clamp(x0 + 1, image.width);
    final y1 = (box.bottom * image.height).toInt().clamp(y0 + 1, image.height);

    double sumR = 0, sumG = 0, sumB = 0;
    int samples = 0;

    const steps = 6;
    final stepX = math.max(1, (x1 - x0) ~/ steps);
    final stepY = math.max(1, (y1 - y0) ~/ steps);

    for (int y = y0; y < y1; y += stepY) {
      for (int x = x0; x < x1; x += stepX) {
        final p = image.getPixel(x, y);
        sumR += p.r / 255.0;
        sumG += p.g / 255.0;
        sumB += p.b / 255.0;
        samples++;
      }
    }

    if (samples == 0) return const [0.5, 0.5, 0.5, 0.5, 1.0];

    final avgR = sumR / samples;
    final avgG = sumG / samples;
    final avgB = sumB / samples;
    final lum = 0.299 * avgR + 0.587 * avgG + 0.114 * avgB;
    final aspect = box.width / (box.height == 0 ? 1 : box.height);

    return [avgR, avgG, avgB, lum, aspect.clamp(0.1, 10.0)];
  }

  List<DetectedObject> _decode(
    List out,
    List<int> shape, {
    required double padX,
    required double padY,
    required double newW,
    required double newH,
  }) {
    // YOLOv8 single-class output: [1, 5, N] (channels first) or [1, N, 5].
    final channelsFirst = shape[1] < shape[2];
    final n = channelsFirst ? shape[2] : shape[1];

    double v(int attr, int i) =>
        ((channelsFirst ? out[attr][i] : out[i][attr]) as num).toDouble();

    final raw = <List<double>>[];
    var maxCoord = 0.0;
    for (var i = 0; i < n; i++) {
      final conf = v(4, i);
      if (conf < _confThreshold) continue;
      final cx = v(0, i), cy = v(1, i), w = v(2, i), h = v(3, i);
      maxCoord = [maxCoord, cx, cy, w, h].reduce((a, b) => a > b ? a : b);
      raw.add([cx, cy, w, h, conf]);
    }

    final isPixels = maxCoord > 2.0;

    final candidates = raw.map((r) {
      // In pixel space on the 640x640 canvas
      final cx = isPixels ? r[0] : r[0] * _inputSize;
      final cy = isPixels ? r[1] : r[1] * _inputSize;
      final w = isPixels ? r[2] : r[2] * _inputSize;
      final h = isPixels ? r[3] : r[3] * _inputSize;

      // Un-pad back into normalized coordinates (0..1) of original photo
      final left = ((cx - w / 2 - padX) / newW).clamp(0.0, 1.0);
      final top = ((cy - h / 2 - padY) / newH).clamp(0.0, 1.0);
      final right = ((cx + w / 2 - padX) / newW).clamp(0.0, 1.0);
      final bottom = ((cy + h / 2 - padY) / newH).clamp(0.0, 1.0);

      return DetectedObject(
        box: Rect.fromLTRB(left, top, right, bottom),
        confidence: r[4],
      );
    }).where((d) => d.box.width > 0.015 && d.box.height > 0.015).toList();

    return _nms(candidates);
  }

  List<DetectedObject> _nms(List<DetectedObject> boxes) {
    boxes.sort((a, b) => b.confidence.compareTo(a.confidence));
    final kept = <DetectedObject>[];
    for (final box in boxes) {
      final overlaps =
          kept.any((k) => _iou(box.box, k.box) > _iouThreshold);
      if (!overlaps) {
        kept.add(box);
        if (kept.length >= _maxDetections) break;
      }
    }
    return kept;
  }

  double _iou(Rect a, Rect b) {
    final inter = a.intersect(b);
    if (inter.width <= 0 || inter.height <= 0) return 0;
    final interArea = inter.width * inter.height;
    final union = a.width * a.height + b.width * b.height - interArea;
    return union <= 0 ? 0 : interArea / union;
  }
}
