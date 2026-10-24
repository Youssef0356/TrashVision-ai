import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detection.dart';
import '../widgets/glass.dart';

class BadgeItem {
  final String id;
  final String title;
  final String titleTn;
  final String description;
  final String descriptionTn;
  final IconData icon;
  final Color color;
  final int requiredCount;
  final int currentCount;
  final bool isUnlocked;
  final int xpReward;
  final DateTime? unlockedAt;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.titleTn,
    required this.description,
    required this.descriptionTn,
    required this.icon,
    required this.color,
    required this.requiredCount,
    required this.currentCount,
    required this.isUnlocked,
    required this.xpReward,
    this.unlockedAt,
  });

  double get progressRatio => (currentCount / requiredCount).clamp(0.0, 1.0);
}

/// Persisted progression, customizable cleanup goals, and language economy.
class GameService extends ChangeNotifier {
  static final GameService instance = GameService._internal();
  GameService._internal();

  static const int xpPerLevel = 200;
  static const _ranks = [
    'Scout',
    'Field Specialist',
    'Eco Sentinel',
    'Clean Architect',
    'Planet Guardian',
  ];

  static const _ranksTn = [
    'كشاف الحومة',
    'مختص النظافة',
    'حارس البيئة',
    'مهندس النظافة',
    'بطل تونس الخضراء',
  ];

  SharedPreferences? _prefs;
  int _availableXp = 0;
  int _lifetimeXp = 0;
  int _totalCleaned = 0;

  // Customizable User Goal System (Replacing Streak)
  int _dailyGoal = 10;
  int _todayCleaned = 0;
  String? _lastDay;

  // Tunisian Derja Language Toggle
  bool _isTunisian = false;

  final List<CleanupRecord> _history = [];
  final Map<String, DateTime> _unlockedBadges = {};

  int get availableXp => _availableXp;
  int get lifetimeXp => _lifetimeXp;
  int get totalCleaned => _totalCleaned;
  int get dailyGoal => _dailyGoal;
  int get todayCleaned => _todayCleaned;
  double get goalProgress => (_todayCleaned / (_dailyGoal == 0 ? 1 : _dailyGoal)).clamp(0.0, 1.0);
  bool get isGoalCompleted => _todayCleaned >= _dailyGoal;
  bool get isTunisian => _isTunisian;

  List<CleanupRecord> get history => List.unmodifiable(_history);
  Map<String, DateTime> get unlockedBadges => Map.unmodifiable(_unlockedBadges);

  int get level => (_lifetimeXp ~/ xpPerLevel) + 1;
  int get xpIntoLevel => _lifetimeXp % xpPerLevel;
  double get levelProgress => xpIntoLevel / xpPerLevel;
  String get rank => _isTunisian
      ? _ranksTn[(level - 1).clamp(0, _ranksTn.length - 1)]
      : _ranks[(level - 1).clamp(0, _ranks.length - 1)];

  static int xpFor(int itemsCleaned, int score) =>
      itemsCleaned * 25 + (itemsCleaned > 0 && score >= 90 ? 40 : 0);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    _availableXp = prefs.getInt('available_xp') ?? prefs.getInt('xp') ?? 0;
    _lifetimeXp = prefs.getInt('lifetime_xp') ?? _availableXp;
    _totalCleaned = prefs.getInt('cleaned') ?? 0;
    _dailyGoal = prefs.getInt('daily_goal') ?? 10;
    _todayCleaned = prefs.getInt('today_cleaned') ?? 0;
    _lastDay = prefs.getString('lastDay');
    _isTunisian = prefs.getBool('is_tunisian') ?? false;

    final today = _dayKey(DateTime.now());
    if (_lastDay != today) {
      _todayCleaned = 0;
      _lastDay = today;
    }

    // Load unlocked badges
    final badgesRaw = prefs.getString('unlocked_badges_json');
    if (badgesRaw != null) {
      try {
        final map = jsonDecode(badgesRaw) as Map<String, dynamic>;
        map.forEach((k, v) {
          _unlockedBadges[k] = DateTime.parse(v as String);
        });
      } catch (_) {}
    }

    for (final s in prefs.getStringList('history') ?? const <String>[]) {
      try {
        _history.add(CleanupRecord.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }

    notifyListeners();
  }

  void setDailyGoal(int newGoal) {
    if (newGoal <= 0) return;
    _dailyGoal = newGoal;
    _save();
    notifyListeners();
  }

  void toggleLanguage() {
    _isTunisian = !_isTunisian;
    _save();
    notifyListeners();
  }

  List<BadgeItem> get badges {
    final spotlessCount = _history.where((r) => r.score >= 100).length;

    final definitions = [
      BadgeItem(
        id: 'first_spark',
        title: 'First Spark',
        titleTn: 'أول قطرة',
        description: 'Completed your very first verified cleanup quest.',
        descriptionTn: 'كمّلت أول عملية تنظيف مثبتة بالـ AI.',
        icon: CupertinoIcons.sparkles,
        color: AppleColors.green,
        requiredCount: 1,
        currentCount: _history.length,
        isUnlocked: _unlockedBadges.containsKey('first_spark'),
        xpReward: 50,
        unlockedAt: _unlockedBadges['first_spark'],
      ),
      BadgeItem(
        id: 'spotless_100',
        title: 'Pure Spotless',
        titleTn: 'تشعل شعيل',
        description: 'Achieved 100% spotless clearance on a cleanup.',
        descriptionTn: 'نظافة 100% وما خليت حتى وسخة في البلاصة.',
        icon: CupertinoIcons.checkmark_seal_fill,
        color: AppleColors.blue,
        requiredCount: 1,
        currentCount: spotlessCount,
        isUnlocked: _unlockedBadges.containsKey('spotless_100'),
        xpReward: 100,
        unlockedAt: _unlockedBadges['spotless_100'],
      ),
      BadgeItem(
        id: 'clean_10',
        title: 'Litter Hunter',
        titleTn: 'صياد الوسخ',
        description: 'Cleaned a total of 10 litter items.',
        descriptionTn: 'نحّيت 10 قطايع وسخ من الحومة.',
        icon: CupertinoIcons.bin_xmark_fill,
        color: AppleColors.orange,
        requiredCount: 10,
        currentCount: _totalCleaned,
        isUnlocked: _unlockedBadges.containsKey('clean_10'),
        xpReward: 150,
        unlockedAt: _unlockedBadges['clean_10'],
      ),
      BadgeItem(
        id: 'goal_crusher',
        title: 'Goal Crusher',
        titleTn: 'قد الكلمة',
        description: 'Completed your custom daily cleanup target.',
        descriptionTn: 'خلطت للهدف اليومي اللي حطيتو لروحك.',
        icon: CupertinoIcons.scope,
        color: AppleColors.green,
        requiredCount: 1,
        currentCount: isGoalCompleted ? 1 : 0,
        isUnlocked: _unlockedBadges.containsKey('goal_crusher'),
        xpReward: 200,
        unlockedAt: _unlockedBadges['goal_crusher'],
      ),
      BadgeItem(
        id: 'clean_50',
        title: 'Eco Sentinel',
        titleTn: 'حامي الحومة',
        description: 'Cleaned 50 litter items from your community.',
        descriptionTn: 'نظفت 50 وسخة من الشارع والبلاد.',
        icon: CupertinoIcons.shield_fill,
        color: AppleColors.purple,
        requiredCount: 50,
        currentCount: _totalCleaned,
        isUnlocked: _unlockedBadges.containsKey('clean_50'),
        xpReward: 300,
        unlockedAt: _unlockedBadges['clean_50'],
      ),
      BadgeItem(
        id: 'clean_100',
        title: 'Earth Legend',
        titleTn: 'أسطورة النظافة',
        description: 'Cleaned 100 pieces of trash. Pure dedication.',
        descriptionTn: 'نحيت 100 وسخة كاملين. يعطيك ألف صحة!',
        icon: CupertinoIcons.star_fill,
        color: const Color(0xFFFFD60A),
        requiredCount: 100,
        currentCount: _totalCleaned,
        isUnlocked: _unlockedBadges.containsKey('clean_100'),
        xpReward: 1000,
        unlockedAt: _unlockedBadges['clean_100'],
      ),
    ];

    return definitions;
  }

  CleanupRecord recordCleanup({required int itemsCleaned, required int score}) {
    final now = DateTime.now();
    final xp = xpFor(itemsCleaned, score);
    final today = _dayKey(now);

    if (_lastDay != today) {
      _todayCleaned = 0;
      _lastDay = today;
    }

    _todayCleaned += itemsCleaned;
    _availableXp += xp;
    _lifetimeXp += xp;
    _totalCleaned += itemsCleaned;

    final record = CleanupRecord(
      itemsCleaned: itemsCleaned,
      score: score,
      xp: xp,
      time: now,
    );
    _history.insert(0, record);
    if (_history.length > 50) _history.removeLast();

    _checkBadges(record);

    _save();
    notifyListeners();
    return record;
  }

  void _checkBadges(CleanupRecord latest) {
    void unlock(String id, int xpBonus) {
      if (!_unlockedBadges.containsKey(id)) {
        _unlockedBadges[id] = DateTime.now();
        _availableXp += xpBonus;
        _lifetimeXp += xpBonus;
      }
    }

    if (_history.isNotEmpty) unlock('first_spark', 50);
    if (latest.score >= 100 && latest.itemsCleaned > 0) unlock('spotless_100', 100);
    if (_totalCleaned >= 10) unlock('clean_10', 150);
    if (isGoalCompleted) unlock('goal_crusher', 200);
    if (_totalCleaned >= 50) unlock('clean_50', 300);
    if (_totalCleaned >= 100) unlock('clean_100', 1000);
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    await p.setInt('available_xp', _availableXp);
    await p.setInt('lifetime_xp', _lifetimeXp);
    await p.setInt('cleaned', _totalCleaned);
    await p.setInt('daily_goal', _dailyGoal);
    await p.setInt('today_cleaned', _todayCleaned);
    await p.setBool('is_tunisian', _isTunisian);
    if (_lastDay != null) await p.setString('lastDay', _lastDay!);

    final badgeMap = <String, String>{};
    _unlockedBadges.forEach((k, v) => badgeMap[k] = v.toIso8601String());
    await p.setString('unlocked_badges_json', jsonEncode(badgeMap));

    await p.setStringList(
      'history',
      _history.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
