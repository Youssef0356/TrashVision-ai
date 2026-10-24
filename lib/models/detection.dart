import 'package:flutter/material.dart';

class DetectedObject {
  final Rect boundingBox; // Normalized (0.0 to 1.0)
  final String label;
  final double confidence;
  final Color color;

  DetectedObject({
    required this.boundingBox,
    required this.label,
    required this.confidence,
    Color? color,
  }) : color = color ?? _getColorForLabel(label);

  static Color _getColorForLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('plastic')) return Colors.orangeAccent;
    if (lower.contains('bottle') || lower.contains('glass')) return Colors.cyanAccent;
    if (lower.contains('can') || lower.contains('metal')) return Colors.amberAccent;
    if (lower.contains('carton') || lower.contains('paper')) return Colors.greenAccent;
    if (lower.contains('cigarette')) return Colors.redAccent;
    return Colors.lightGreenAccent;
  }
}

class QuestResult {
  final String id;
  final String beforeImagePath;
  final String afterImagePath;
  final List<DetectedObject> beforeDetections;
  final List<DetectedObject> afterDetections;
  final double cleanlinessScore; // 0 to 100
  final int xpEarned;
  final DateTime timestamp;

  QuestResult({
    required this.id,
    required this.beforeImagePath,
    required this.afterImagePath,
    required this.beforeDetections,
    required this.afterDetections,
    required this.cleanlinessScore,
    required this.xpEarned,
    required this.timestamp,
  });

  int get itemsCleaned =>
      (beforeDetections.length - afterDetections.length).clamp(0, 999);
}
