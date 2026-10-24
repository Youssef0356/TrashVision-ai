import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:trashvision_ai/models/detection.dart';
import 'package:trashvision_ai/services/game_service.dart';

void main() {
  test('xp rewards cleared items and a bonus for a spotless result', () {
    expect(GameService.xpFor(0, 0), 0);
    expect(GameService.xpFor(3, 60), 75);
    expect(GameService.xpFor(3, 100), 115);
  });

  test('spatial comparison recognizes cleaned paper even when new items are added', () {
    // 4 items in Before: Paper at (0.5, 0.5), plus 3 other objects at distinct coordinates
    final before = [
      const DetectedObject(box: Rect.fromLTWH(0.45, 0.45, 0.1, 0.1), confidence: 0.85), // Paper
      const DetectedObject(box: Rect.fromLTWH(0.10, 0.10, 0.08, 0.08), confidence: 0.90), // Item 2
      const DetectedObject(box: Rect.fromLTWH(0.80, 0.15, 0.10, 0.10), confidence: 0.88), // Item 3
      const DetectedObject(box: Rect.fromLTWH(0.20, 0.80, 0.12, 0.12), confidence: 0.80), // Item 4
    ];

    // After: Paper is removed! The 3 other items remain at their coordinates,
    // and 4 brand new items are placed in different spots
    final after = [
      const DetectedObject(box: Rect.fromLTWH(0.10, 0.10, 0.08, 0.08), confidence: 0.91), // Item 2 still here
      const DetectedObject(box: Rect.fromLTWH(0.80, 0.15, 0.10, 0.10), confidence: 0.87), // Item 3 still here
      const DetectedObject(box: Rect.fromLTWH(0.20, 0.80, 0.12, 0.12), confidence: 0.82), // Item 4 still here
      // 4 newly introduced items
      const DetectedObject(box: Rect.fromLTWH(0.02, 0.50, 0.05, 0.05), confidence: 0.75),
      const DetectedObject(box: Rect.fromLTWH(0.90, 0.90, 0.05, 0.05), confidence: 0.70),
      const DetectedObject(box: Rect.fromLTWH(0.60, 0.05, 0.06, 0.06), confidence: 0.80),
      const DetectedObject(box: Rect.fromLTWH(0.05, 0.95, 0.04, 0.04), confidence: 0.72),
    ];

    final result = CleanupComparison.evaluate(before: before, after: after);

    // Paper was successfully cleaned!
    expect(result.itemsCleaned, 1);
    expect(result.remainingItems.length, 3);
    expect(result.newItems.length, 4);
    expect(result.score, 25);
  });
}
