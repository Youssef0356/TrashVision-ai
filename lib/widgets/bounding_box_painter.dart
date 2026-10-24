import 'package:flutter/material.dart';
import '../models/detection.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectedObject> detections;

  BoundingBoxPainter({required this.detections});

  @override
  void paint(Canvas canvas, Size size) {
    for (final detection in detections) {
      final rect = Rect.fromLTRB(
        detection.boundingBox.left * size.width,
        detection.boundingBox.top * size.height,
        detection.boundingBox.right * size.width,
        detection.boundingBox.bottom * size.height,
      );

      final boxPaint = Paint()
        ..color = detection.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // Draw bounding box with rounded corners
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, boxPaint);

      // Draw label background pill
      final labelText = '${detection.label} ${(detection.confidence * 100).toInt()}%';
      final textSpan = TextSpan(
        text: labelText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final labelBgRect = Rect.fromLTWH(
        rect.left,
        (rect.top - 22 < 0) ? rect.top : rect.top - 22,
        textPainter.width + 12,
        20,
      );

      final bgPaint = Paint()
        ..color = detection.color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(RRect.fromRectAndRadius(labelBgRect, const Radius.circular(4)), bgPaint);

      textPainter.paint(
        canvas,
        Offset(labelBgRect.left + 6, labelBgRect.top + 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.detections != detections;
  }
}
