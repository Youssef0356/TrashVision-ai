import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../widgets/tactile_button.dart';
import 'quest_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    GameService.instance.addListener(_onGameUpdated);
  }

  @override
  void dispose() {
    GameService.instance.removeListener(_onGameUpdated);
    super.dispose();
  }

  void _onGameUpdated() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final game = GameService.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF111714),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Tactical Top Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System status bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF55A630),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'TRASHVISION AI // ONLINE',
                              style: TextStyle(
                                color: Color(0xFF809B8B),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFF48C06).withAlpha(120)),
                            borderRadius: BorderRadius.circular(4),
                            color: const Color(0xFFF48C06).withAlpha(25),
                          ),
                          child: Text(
                            '🔥 ${game.currentStreakDays}-DAY STREAK',
                            style: const TextStyle(
                              color: Color(0xFFF48C06),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Expedition Dossier Card
                    _buildDossierCard(game),
                  ],
                ),
              ),
            ),

            // Field Vitals Metric Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricBlock(
                        title: 'WASTE ELIMINATED',
                        value: '${game.totalCleanedItems}',
                        unit: 'ITEMS',
                        accent: const Color(0xFF55A630),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricBlock(
                        title: 'CLEAN MISSIONS',
                        value: '${game.history.length}',
                        unit: 'OPS',
                        accent: const Color(0xFF2A9D8F),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricBlock(
                        title: 'TRASHVISION XP',
                        value: '${game.totalXp}',
                        unit: 'PTS',
                        accent: const Color(0xFFF48C06),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Primary Call To Action Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF19231D),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2C3E34), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE85D04).withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'VISION ENGINE ARMED',
                              style: TextStyle(
                                color: Color(0xFFE85D04),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const Icon(Icons.remove_red_eye_rounded, color: Color(0xFF809B8B), size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Start Clean Mission',
                        style: TextStyle(
                          color: Color(0xFFEBE5D8),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '1. Snap litter with TrashVision scanner (Before)\n2. Clean and dispose of waste\n3. Rescan to let AI score your work and award XP',
                        style: TextStyle(
                          color: Color(0xFFA1B3A8),
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),

                      TactileButton(
                        backgroundColor: const Color(0xFFE85D04),
                        shadowColor: const Color(0xFF9D0208),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const QuestScreen()),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.center_focus_strong, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'ACTIVATE TRASHVISION',
                              style: TextStyle(fontFamily: 'monospace', fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Activity Log Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AI AUDIT LOGS',
                      style: TextStyle(
                        color: Color(0xFFEBE5D8),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      '${game.history.length} VERIFIED',
                      style: const TextStyle(
                        color: Color(0xFF809B8B),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Log Cards
            if (game.history.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF19231D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2C3E34)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.camera_enhance_outlined, size: 40, color: Color(0xFF43584C)),
                      SizedBox(height: 12),
                      Text(
                        'NO AUDITS LOGGED TODAY',
                        style: TextStyle(
                          color: Color(0xFFEBE5D8),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Spot some litter and scan it to start your cleaning streak.',
                        style: TextStyle(color: Color(0xFF809B8B), fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final quest = game.history[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF19231D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2C3E34)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D6A4F).withAlpha(40),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF55A630)),
                              ),
                              child: const Icon(Icons.verified_rounded, color: Color(0xFF55A630), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'AUDIT #${quest.id.substring(quest.id.length - 4)}',
                                        style: const TextStyle(
                                          color: Color(0xFFEBE5D8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${quest.itemsCleaned} items removed • ${quest.cleanlinessScore.toInt()}% restored',
                                    style: const TextStyle(color: Color(0xFF809B8B), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF48C06).withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+${quest.xpEarned} XP',
                                style: const TextStyle(
                                  color: Color(0xFFF48C06),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: game.history.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildDossierCard(GameService game) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF19231D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2C3E34), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6A4F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF55A630), width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.remove_red_eye_outlined, color: Color(0xFFEBE5D8), size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.rankTitle.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFEBE5D8),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'AI OPERATOR LVL ${game.currentLevel} • VISION V2.0',
                      style: const TextStyle(
                        color: Color(0xFF809B8B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NEXT LEVEL CLEARANCE',
                    style: TextStyle(
                      color: Color(0xFF809B8B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    '${game.xpForCurrentLevel} / 200 XP',
                    style: const TextStyle(
                      color: Color(0xFFEBE5D8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildSegmentedBar(game.levelProgress),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedBar(double progress) {
    const totalSegments = 16;
    final activeSegments = (progress * totalSegments).round();

    return Row(
      children: List.generate(totalSegments, (index) {
        final isActive = index < activeSegments;
        return Expanded(
          child: Container(
            height: 7,
            margin: EdgeInsets.only(right: index == totalSegments - 1 ? 0 : 3),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF55A630) : const Color(0xFF2C3E34),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMetricBlock({
    required String title,
    required String value,
    required String unit,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF19231D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2C3E34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF809B8B),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: Color(0xFF809B8B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
