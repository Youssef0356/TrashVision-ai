import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../widgets/glass.dart';

/// Badges & Achievements Screen (Full Derja & English Support)
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameService.instance;
    final tn = game.isTunisian;
    final badges = game.badges;
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 95),
      children: [
        // Top Header
        Row(
          children: [
            const Icon(CupertinoIcons.rosette, size: 22, color: AppleColors.ink),
            const SizedBox(width: 8),
            Text(
              tn ? 'الأوسمة والتحديات' : 'Achievements & Badges',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppleColors.ink,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          tn
              ? 'نظّف، خلط لهدفك اليومي، واربح أوسمة تثبّت خدمتك لبلادك.'
              : 'Clean litter, crush your daily goals, and unlock verified eco badges.',
          style: const TextStyle(fontSize: 13, color: AppleColors.secondary),
        ),
        const SizedBox(height: 18),

        // Rank & Mastery Overview Card
        AppleGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppleColors.sunsetStart, AppleColors.sunsetEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x30FF8C00),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(CupertinoIcons.star_fill, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.rank.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppleColors.ink,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            tn
                                ? 'المستوى ${game.level} • ${game.lifetimeXp} مجموع النقاط'
                                : 'Level ${game.level} • ${game.lifetimeXp} Total XP',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppleColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppleGlassPill(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      tn ? '$unlockedCount / ${badges.length} أوسمة' : '$unlockedCount / ${badges.length} Badges',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppleColors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Level Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: game.levelProgress,
                  minHeight: 8,
                  backgroundColor: AppleColors.canvas,
                  valueColor: const AlwaysStoppedAnimation(AppleColors.green),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${game.xpIntoLevel} / ${GameService.xpPerLevel} XP',
                    style: const TextStyle(fontSize: 11, color: AppleColors.tertiary, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    tn
                        ? 'مازال ${GameService.xpPerLevel - game.xpIntoLevel} نقطة للمستوى ${game.level + 1}'
                        : '${GameService.xpPerLevel - game.xpIntoLevel} XP to Level ${game.level + 1}',
                    style: const TextStyle(fontSize: 11, color: AppleColors.secondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Badges Section Title
        Text(
          tn ? 'قائمة الأوسمة' : 'Available Badges',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppleColors.ink,
          ),
        ),
        const SizedBox(height: 12),

        // Badges List
        ...badges.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BadgeCard(badge: b, tn: tn),
            )),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeItem badge;
  final bool tn;

  const _BadgeCard({required this.badge, required this.tn});

  @override
  Widget build(BuildContext context) {
    return AppleGlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: badge.isUnlocked ? badge.color.withAlpha(90) : AppleColors.border,
      backgroundColor: badge.isUnlocked ? Colors.white : Colors.white.withAlpha(200),
      child: Row(
        children: [
          // Badge Icon Circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badge.isUnlocked ? badge.color.withAlpha(25) : AppleColors.canvas,
              border: Border.all(
                color: badge.isUnlocked ? badge.color : AppleColors.border,
                width: 2,
              ),
            ),
            child: Icon(
              badge.icon,
              size: 24,
              color: badge.isUnlocked ? badge.color : AppleColors.tertiary,
            ),
          ),
          const SizedBox(width: 16),

          // Badge Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tn ? badge.titleTn : badge.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: badge.isUnlocked ? AppleColors.ink : AppleColors.secondary,
                      ),
                    ),
                    if (badge.isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppleColors.green.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.checkmark_alt, size: 11, color: AppleColors.green),
                            const SizedBox(width: 2),
                            Text(
                              tn ? 'مبروك' : 'UNLOCKED',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: AppleColors.green,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        '+${badge.xpReward} XP',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppleColors.tertiary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  tn ? badge.descriptionTn : badge.description,
                  style: const TextStyle(fontSize: 12, color: AppleColors.secondary, height: 1.25),
                ),
                const SizedBox(height: 8),

                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: badge.progressRatio,
                          minHeight: 5,
                          backgroundColor: AppleColors.canvas,
                          valueColor: AlwaysStoppedAnimation(
                            badge.isUnlocked ? badge.color : AppleColors.tertiary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${badge.currentCount.clamp(0, badge.requiredCount)}/${badge.requiredCount}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppleColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
