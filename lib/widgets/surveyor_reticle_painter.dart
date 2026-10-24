import 'package:flutter/material.dart';
import '../models/detection.dart';

class SurveyorReticlePainter extends CustomPainter {
  final List<DetectedObject> detections;
  final double scanProgress; // 0.0 to 1.0 for sweep line

  SurveyorReticlePainter({
    required this.detections,
    this.scanProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle holographic rangefinder grid ticks
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..strokeWidth = 1.0;

    // Center crosshair
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(cx - 15, cy), Offset(cx + 15, cy), gridPaint);
    canvas.drawLine(Offset(cx, cy - 15), Offset(cx, cy + 15), gridPaint);

    // 2. Draw tactical target brackets for each detection
    int index = 1;
    for (final detection in detections) {
      final rect = Rect.fromLTRB(
        detection.boundingBox.left * size.width,
        detection.boundingBox.top * size.height,
        detection.boundingBox.right * size.width,
        detection.boundingBox.bottom * size.height,
      );

      final accentColor = const Color(0xFFF48C06); // High-vis surveyor amber
      final bracketPaint = Paint()
        ..color = accentColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      const cornerLen = 14.0;

      // Top-Left corner ⌜
      canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(cornerLen, 0), bracketPaint);
      canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, cornerLen), bracketPaint);

      // Top-Right corner ⌝
      canvas.drawLine(rect.topRight, rect.topRight - const Offset(cornerLen, 0), bracketPaint);
      canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, cornerLen), bracketPaint);

      // Bottom-Left corner ⌞
      canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(cornerLen, 0), bracketPaint);
      canvas.drawLine(rect.bottomLeft, rect.bottomLeft - const Offset(0, cornerLen), bracketPaint);

      // Bottom-Right corner ⌟
      canvas.drawLine(rect.bottomRight, rect.bottomRight - const Offset(cornerLen, 0), bracketPaint);
      canvas.drawLine(rect.bottomRight, rect.bottomRight - const Offset(0, cornerLen), bracketPaint);

      // Center crosshair inside specimen
      final boxCenter = rect.center;
      final crossPaint = Paint()
        ..color = accentColor.withAlpha(140)
        ..strokeWidth = 1.0;
      canvas.drawLine(boxCenter - const Offset(6, 0), boxCenter + const Offset(6, 0), crossPaint);
      canvas.drawLine(boxCenter - const Offset(0, 6), boxCenter + const Offset(0, 6), crossPaint);

      // Specimen Tactical Tag
      final tagText = 'SP-$index: ${detection.label.toUpperCase()} [${(detection.confidence * 100).toInt()}%]';
      final textSpan = TextSpan(
        text: tagText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          fontFamily: 'monospace',
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final tagTop = (rect.top - 18 < 0) ? rect.top : rect.top - 18;
      final tagRect = Rect.fromLTWH(rect.left, tagTop, textPainter.width + 10, 16);

      canvas.drawRect(tagRect, Paint()..color = accentColor);
      textPainter.paint(canvas, Offset(tagRect.left + 5, tagRect.top + 2));

      index++;
    }
  }

  @override
  bool shouldRepaint(covariant SurveyorReticlePainter oldDelegate) {
    return oldDelegate.detections != detections ||
        oldDelegate.scanProgress != scanProgress;
  }
}
