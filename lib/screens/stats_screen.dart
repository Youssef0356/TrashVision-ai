import 'package:flutter/cupertino.dart';
import '../models/detection.dart';
import '../services/game_service.dart';
import '../widgets/glass.dart';
import '../widgets/goal_setup_sheet.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _timeAgo(DateTime t, bool tn) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return tn ? 'توا توا' : 'Just now';
    if (d.inHours < 1) return tn ? 'منذ ${d.inMinutes} دقيقة' : '${d.inMinutes}m ago';
    if (d.inDays < 1) return tn ? 'منذ ${d.inHours} ساعة' : '${d.inHours}h ago';
    return tn ? 'منذ ${d.inDays} يوم' : '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final game = GameService.instance;
    final tn = game.isTunisian;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        // Header
        Text(
          tn ? 'البصمة والإحصائيات' : 'Impact & Statistics',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppleColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tn
              ? 'إحصائيات مثبتة مباشرة بالذكاء الاصطناعي على هاتفك.'
              : 'Verified telemetry from your on-device AI.',
          style: const TextStyle(fontSize: 14, color: AppleColors.secondary),
        ),
        const SizedBox(height: 20),

        // Hero Progress Card
        AppleGlassCard(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              AppleScoreRing(
                progress: game.levelProgress,
                size: 96,
                stroke: 9,
                activeColor: AppleColors.green,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LV ${game.level}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppleColors.ink,
                      ),
                    ),
                    Text(
                      '${(game.levelProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppleColors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.rank,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppleColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tn
                          ? '${game.xpIntoLevel} / ${GameService.xpPerLevel} نقطة للمستوى ${game.level + 1}'
                          : '${game.xpIntoLevel} / ${GameService.xpPerLevel} XP to Level ${game.level + 1}',
                      style: const TextStyle(fontSize: 13, color: AppleColors.secondary),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppleColors.canvas,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppleColors.border),
                      ),
                      child: Text(
                        tn ? 'مجموع النقاط: ${game.lifetimeXp}' : 'Lifetime XP: ${game.lifetimeXp}',
                        style: const TextStyle(
                          color: AppleColors.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3 Key Vitals Grid (Streak replaced with Goal!)
        Row(
          children: [
            Expanded(
              child: _VitalCard(
                icon: CupertinoIcons.delete_solid,
                iconColor: AppleColors.blue,
                value: '${game.totalCleaned}',
                label: tn ? 'وسخ تنحى' : 'Trash Cleared',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => GoalSetupSheet.show(context),
                child: _VitalCard(
                  icon: game.isGoalCompleted ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.scope,
                  iconColor: game.isGoalCompleted ? AppleColors.green : AppleColors.orange,
                  value: '${game.todayCleaned}/${game.dailyGoal}',
                  label: tn ? 'هدف اليوم (بدّل)' : 'Daily Goal',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _VitalCard(
                icon: CupertinoIcons.rosette,
                iconColor: AppleColors.purple,
                value: '${game.unlockedBadges.length}',
                label: tn ? 'أوسمة رابحة' : 'Badges Won',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Recent Activity Title
        Text(
          tn ? 'تاريخ التنظيف السابق' : 'Recent Verified Cleanups',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppleColors.ink,
          ),
        ),
        const SizedBox(height: 12),

        if (game.history.isEmpty)
          AppleGlassCard(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  const Icon(CupertinoIcons.camera_viewfinder, size: 40, color: AppleColors.tertiary),
                  const SizedBox(height: 12),
                  Text(
                    tn ? 'مازلت ما نظفت حتى بلاصة' : 'No cleanups recorded yet',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppleColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tn
                        ? 'امشي للـ "صوّر"، وجّه الكاميرا للوسخ وابدا اول تحدي!'
                        : 'Head to "Scan", point the lens at litter, and complete your first quest!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppleColors.secondary),
                  ),
                ],
              ),
            ),
          )
        else
          ...game.history.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HistoryCard(record: record, tn: tn, timeAgo: _timeAgo(record.time, tn)),
            ),
          ),
      ],
    );
  }
}

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _VitalCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppleGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppleColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppleColors.secondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CleanupRecord record;
  final bool tn;
  final String timeAgo;

  const _HistoryCard({
    required this.record,
    required this.tn,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final spotless = record.score >= 100;

    return AppleGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: spotless ? AppleColors.green.withAlpha(25) : AppleColors.orange.withAlpha(25),
            ),
            child: Icon(
              spotless ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.checkmark_alt,
              color: spotless ? AppleColors.green : AppleColors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tn
                      ? '${record.itemsCleaned} قطايع وسخ تنحاو'
                      : '${record.itemsCleaned} items removed',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppleColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeAgo,
                  style: const TextStyle(fontSize: 12, color: AppleColors.secondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${record.xp} XP',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppleColors.green,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${record.score}% ${tn ? (spotless ? 'تشعل' : 'نظيفة') : (spotless ? 'Spotless' : 'Clean')}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppleColors.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
