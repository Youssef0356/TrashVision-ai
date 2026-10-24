import 'package:flutter/material.dart';
import '../models/detection.dart';
import '../services/game_service.dart';
import 'glass.dart';

/// Clean, sharp bounding reticles over detected litter.
class DetectionPainter extends CustomPainter {
  final List<DetectedObject> detections;
  final Set<DetectedObject>? cleanedSet;

  DetectionPainter(this.detections, {this.cleanedSet});

  @override
  void paint(Canvas canvas, Size size) {
    final tn = GameService.instance.isTunisian;
    for (var i = 0; i < detections.length; i++) {
      final d = detections[i];
      final b = d.box;
      final rect = Rect.fromLTRB(
        b.left * size.width,
        b.top * size.height,
        b.right * size.width,
        b.bottom * size.height,
      );
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(14));

      final isCleaned = cleanedSet?.contains(d) ?? false;
      final hasComparison = cleanedSet != null;

      final primaryColor = hasComparison
          ? (isCleaned ? AppleColors.green : AppleColors.orange)
          : AppleColors.green;

      // Outer contrasting halo
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..color = Colors.white,
      );

      // Primary border
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = primaryColor,
      );

      // Minimal floating tag pill
      final tagText = hasComparison
          ? (isCleaned ? (tn ? '✓ تنحّات' : '✓ CLEANED') : (tn ? '! مازالت' : '! REMAINING'))
          : '#${i + 1}  ${(d.confidence * 100).toInt()}%';

      final tp = TextPainter(
        text: TextSpan(
          text: tagText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final pillTop = (rect.top - 24 < 4) ? rect.top + 6 : rect.top - 24;
      final pillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, pillTop, tp.width + 16, 22),
        const Radius.circular(11),
      );

      canvas.drawRRect(pillRect, Paint()..color = primaryColor);
      tp.paint(canvas, Offset(pillRect.left + 8, pillRect.top + 4));
    }
  }

  @override
  bool shouldRepaint(covariant DetectionPainter old) =>
      old.detections != detections || old.cleanedSet != cleanedSet;
}
