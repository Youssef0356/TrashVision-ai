import 'dart:math' as math;
import 'package:flutter/painting.dart';

/// One detected piece of litter. [box] is normalized (0..1) relative to the image.
/// [visualFeatures] contains color/luminance/aspect signature [avgR, avgG, avgB, lum, aspect]
/// used to differentiate objects even when camera angles shift or new items are added.
class DetectedObject {
  final Rect box;
  final double confidence;
  final List<double>? visualFeatures;

  const DetectedObject({
    required this.box,
    required this.confidence,
    this.visualFeatures,
  });

  double get area => box.width * box.height;
}

/// Result of running the model on one photo.
class ScanResult {
  final List<DetectedObject> detections;
  final Size imageSize;

  const ScanResult({required this.detections, required this.imageSize});
}

/// A completed, persisted cleanup.
class CleanupRecord {
  final int itemsCleaned;
  final int score;
  final int xp;
  final DateTime time;

  const CleanupRecord({
    required this.itemsCleaned,
    required this.score,
    required this.xp,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'items': itemsCleaned,
        'score': score,
        'xp': xp,
        'time': time.toIso8601String(),
      };

  factory CleanupRecord.fromJson(Map<String, dynamic> json) => CleanupRecord(
        itemsCleaned: json['items'] as int,
        score: json['score'] as int,
        xp: json['xp'] as int,
        time: DateTime.parse(json['time'] as String),
      );
}

/// High-precision spatial & visual matching between Before and After photos.
/// Matches objects across frames by combining bounding box geometry, scale,
/// and pixel color signatures to prevent false persistence when new items are added.
class CleanupComparison {
  final List<DetectedObject> beforeItems;
  final List<DetectedObject> afterItems;
  final List<DetectedObject> cleanedItems;
  final List<DetectedObject> remainingItems;
  final List<DetectedObject> newItems;
  final int itemsCleaned;
  final int score;

  const CleanupComparison({
    required this.beforeItems,
    required this.afterItems,
    required this.cleanedItems,
    required this.remainingItems,
    required this.newItems,
    required this.itemsCleaned,
    required this.score,
  });

  factory CleanupComparison.evaluate({
    required List<DetectedObject> before,
    required List<DetectedObject> after,
  }) {
    if (before.isEmpty) {
      return CleanupComparison(
        beforeItems: before,
        afterItems: after,
        cleanedItems: const [],
        remainingItems: const [],
        newItems: after,
        itemsCleaned: 0,
        score: 0,
      );
    }

    final matchedAfterIndices = <int>{};
    final cleaned = <DetectedObject>[];
    final remaining = <DetectedObject>[];

    for (final b in before) {
      int bestAfterIdx = -1;
      double bestScore = -1.0;

      for (int j = 0; j < after.length; j++) {
        if (matchedAfterIndices.contains(j)) continue;
        final a = after[j];

        final matchScore = _computeMatchScore(b, a);
        if (matchScore > 0.38 && matchScore > bestScore) {
          bestScore = matchScore;
          bestAfterIdx = j;
        }
      }

      if (bestAfterIdx != -1) {
        matchedAfterIndices.add(bestAfterIdx);
        remaining.add(b);
      } else {
        cleaned.add(b);
      }
    }

    final newItems = <DetectedObject>[];
    for (int j = 0; j < after.length; j++) {
      if (!matchedAfterIndices.contains(j)) {
        newItems.add(after[j]);
      }
    }

    final totalCleaned = cleaned.length;
    final calculatedScore = ((totalCleaned / before.length) * 100).round().clamp(0, 100);

    return CleanupComparison(
      beforeItems: before,
      afterItems: after,
      cleanedItems: cleaned,
      remainingItems: remaining,
      newItems: newItems,
      itemsCleaned: totalCleaned,
      score: calculatedScore,
    );
  }

  static double _computeMatchScore(DetectedObject b, DetectedObject a) {
    final iou = _calculateIoU(b.box, a.box);
    final dist = _centerDistance(b.box, a.box);

    final areaMin = math.min(b.area, a.area);
    final areaMax = math.max(b.area, a.area);
    final areaRatio = areaMax > 0 ? (areaMin / areaMax) : 0.0;

    double visualSim = 0.8; // neutral baseline if no features
    if (b.visualFeatures != null && a.visualFeatures != null) {
      final f1 = b.visualFeatures!;
      final f2 = a.visualFeatures!;
      // f = [r, g, b, lum, aspect]
      final dr = f1[0] - f2[0];
      final dg = f1[1] - f2[1];
      final db = f1[2] - f2[2];
      final colorDist = math.sqrt(dr * dr + dg * dg + db * db) / 1.732; // normalized 0..1
      final lumDist = (f1[3] - f2[3]).abs();

      visualSim = (1.0 - (colorDist * 0.7 + lumDist * 0.3)).clamp(0.0, 1.0);
    }

    // Matching criteria:
    // 1. Direct overlap with compatible visual patch
    if (iou >= 0.12 && visualSim >= 0.40) {
      return (iou * 0.45) + (visualSim * 0.35) + (areaRatio * 0.20);
    }

    // 2. Close centroid distance with compatible size AND compatible visual patch
    // Note: dist <= 0.09 is tight (under 9% of frame) to prevent matching unrelated nearby objects
    if (dist <= 0.09 && areaRatio >= 0.40 && visualSim >= 0.50) {
      return ((1.0 - dist) * 0.35) + (visualSim * 0.45) + (areaRatio * 0.20);
    }

    // Not a match (item was removed, or object is different)
    return 0.0;
  }

  static double _calculateIoU(Rect r1, Rect r2) {
    final intersection = r1.intersect(r2);
    if (intersection.width <= 0 || intersection.height <= 0) return 0.0;
    final interArea = intersection.width * intersection.height;
    final unionArea = (r1.width * r1.height) + (r2.width * r2.height) - interArea;
    return unionArea > 0 ? interArea / unionArea : 0.0;
  }

  static double _centerDistance(Rect r1, Rect r2) {
    final dx = r1.center.dx - r2.center.dx;
    final dy = r1.center.dy - r2.center.dy;
    return math.sqrt(dx * dx + dy * dy);
  }
}
