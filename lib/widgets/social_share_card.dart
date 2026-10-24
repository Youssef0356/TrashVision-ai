import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/detection.dart';
import '../services/game_service.dart';
import 'glass.dart';

/// Full-screen or modal Social Media Story template (Instagram, Snapchat, TikTok style)
class SocialShareModal extends StatelessWidget {
  final File beforeImage;
  final File afterImage;
  final CleanupComparison comparison;
  final int xp;

  const SocialShareModal({
    super.key,
    required this.beforeImage,
    required this.afterImage,
    required this.comparison,
    required this.xp,
  });

  static void show(
    BuildContext context, {
    required File beforeImage,
    required File afterImage,
    required CleanupComparison comparison,
    required int xp,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SocialShareModal(
        beforeImage: beforeImage,
        afterImage: afterImage,
        comparison: comparison,
        xp: xp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tn = GameService.instance.isTunisian;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppleColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tn ? 'بارطاجي النظافة فالستوري' : 'Story Share Template',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppleColors.ink,
                      ),
                    ),
                    Text(
                      tn ? 'جاهزة للنشر على إنستغرام وتيك توك' : 'Ready to share on Instagram, Snapchat or TikTok',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppleColors.secondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppleColors.tertiary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Story Card Container
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Center(
                child: _StoryCard(
                  beforeImage: beforeImage,
                  afterImage: afterImage,
                  comparison: comparison,
                  xp: xp,
                  tn: tn,
                ),
              ),
            ),
          ),

          // Action Buttons (Warm Sunset Gradient instead of black!)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tn ? 'تم حفظ الستوري في ألبوم الصور متاعك!' : 'Story template saved to your camera roll!',
                            ),
                            backgroundColor: AppleColors.ink,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppleColors.canvas,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: AppleColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.arrow_down_to_line, color: AppleColors.ink, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              tn ? 'سجّل التصويرة' : 'Save Image',
                              style: const TextStyle(
                                color: AppleColors.ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tn ? 'قاعد يحل في بارطاج إنستغرام...' : 'Opening share menu for Instagram & WhatsApp...',
                            ),
                            backgroundColor: AppleColors.ink,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: const LinearGradient(
                            colors: [AppleColors.sunsetStart, AppleColors.sunsetEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x35FF8C00),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.share, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              tn ? 'بارطاجي فالستوري' : 'Share to Story',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final File beforeImage;
  final File afterImage;
  final CleanupComparison comparison;
  final int xp;
  final bool tn;

  const _StoryCard({
    required this.beforeImage,
    required this.afterImage,
    required this.comparison,
    required this.xp,
    required this.tn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF141416), // Premium Obsidian Story Backdrop
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Story Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.viewfinder, color: AppleColors.sunsetStart, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    tn ? 'نظّف حومتك' : 'CLEAN YOUR STREET AI',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppleColors.green.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppleColors.green, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.checkmark_seal_fill, color: AppleColors.green, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      tn ? 'مثبّت بالـ AI' : 'VERIFIED',
                      style: const TextStyle(
                        color: AppleColors.green,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Before & After stacked showcase
          Row(
            children: [
              // Before photo
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          Image.file(beforeImage, height: 160, width: double.infinity, fit: BoxFit.cover),
                          Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(180),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tn ? 'قبل' : 'BEFORE',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tn ? '${comparison.beforeItems.length} قطايع وسخ' : '${comparison.beforeItems.length} litter items',
                      style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // After photo
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          Image.file(afterImage, height: 160, width: double.infinity, fit: BoxFit.cover),
                          Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppleColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tn ? 'من بعد' : 'AFTER',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tn ? 'مازال ${comparison.remainingItems.length}' : '${comparison.remainingItems.length} remaining',
                      style: const TextStyle(color: AppleColors.sunsetStart, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Stat Badges Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  label: tn ? 'تنحّاو' : 'CLEANED',
                  value: '${comparison.itemsCleaned}',
                  color: Colors.white,
                ),
                Container(width: 1, height: 26, color: Colors.white24),
                _StatColumn(
                  label: tn ? 'النظافة' : 'SCORE',
                  value: '${comparison.score}%',
                  color: comparison.score >= 80 ? AppleColors.green : AppleColors.orange,
                ),
                Container(width: 1, height: 26, color: Colors.white24),
                _StatColumn(
                  label: tn ? 'نقاط' : 'XP',
                  value: '+$xp',
                  color: AppleColors.sunsetStart,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Story Footer Callout
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.sparkles, color: AppleColors.sunsetStart, size: 12),
              const SizedBox(width: 6),
              Text(
                tn ? 'نظّف حومتك وبلادك بالذكاء الاصطناعي' : 'Making streets clean with on-device AI',
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900, height: 1.1),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
