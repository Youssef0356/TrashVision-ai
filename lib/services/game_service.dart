import 'package:flutter/foundation.dart';
import '../models/detection.dart';

class GameService extends ChangeNotifier {
  static final GameService instance = GameService._internal();
  GameService._internal();

  int _totalXp = 120;
  int _totalCleanedItems = 8;
  int _currentStreakDays = 3;
  final List<QuestResult> _history = [];

  int get totalXp => _totalXp;
  int get totalCleanedItems => _totalCleanedItems;
  int get currentStreakDays => _currentStreakDays;
  List<QuestResult> get history => List.unmodifiable(_history);

  int get currentLevel => (_totalXp ~/ 200) + 1;
  int get xpForCurrentLevel => (_totalXp % 200);
  double get levelProgress => xpForCurrentLevel / 200.0;

  String get rankTitle {
    if (currentLevel == 1) return 'Eco Novice 🌱';
    if (currentLevel == 2) return 'Litter Hunter 🔍';
    if (currentLevel == 3) return 'Green Ranger 🛡️';
    if (currentLevel == 4) return 'Clean Crusader ⚡';
    return 'Planet Guardian 🌍👑';
  }

  void incrementStreak() {
    _currentStreakDays++;
    notifyListeners();
  }

  QuestResult completeQuest({
    required String beforeImagePath,
    required String afterImagePath,
    required List<DetectedObject> beforeDetections,
    required List<DetectedObject> afterDetections,
  }) {
    final beforeCount = beforeDetections.length;
    final afterCount = afterDetections.length;

    double cleanlinessScore = 100.0;
    if (beforeCount > 0) {
      final cleaned = (beforeCount - afterCount).clamp(0, beforeCount);
      cleanlinessScore = (cleaned / beforeCount) * 100.0;
    }

    final itemsCleaned = (beforeCount - afterCount).clamp(0, 999);
    int earnedXp = (itemsCleaned * 30) + (cleanlinessScore >= 90 ? 50 : 20);
    if (beforeCount == 0 && afterCount == 0) {
      earnedXp = 10;
    }

    _totalXp += earnedXp;
    _totalCleanedItems += itemsCleaned;

    final result = QuestResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      beforeImagePath: beforeImagePath,
      afterImagePath: afterImagePath,
      beforeDetections: beforeDetections,
      afterDetections: afterDetections,
      cleanlinessScore: cleanlinessScore,
      xpEarned: earnedXp,
      timestamp: DateTime.now(),
    );

    _history.insert(0, result);
    notifyListeners();
    return result;
  }
}
