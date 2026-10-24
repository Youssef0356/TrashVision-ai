import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/detection.dart';
import '../services/detector_service.dart';
import '../services/game_service.dart';
import '../widgets/before_after_slider.dart';
import '../widgets/detection_painter.dart';
import '../widgets/glass.dart';
import '../widgets/goal_setup_sheet.dart';
import '../widgets/social_share_card.dart';
import 'rewards_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0; // 0 = Scan, 1 = Impact, 2 = Badges
  final GameService _game = GameService.instance;

  @override
  void initState() {
    super.initState();
    _game.addListener(_onGameUpdate);
  }

  @override
  void dispose() {
    _game.removeListener(_onGameUpdate);
    super.dispose();
  }

  void _onGameUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tn = _game.isTunisian;

    return Scaffold(
      backgroundColor: AppleColors.canvas,
      body: Stack(
        children: [
          // Active Tab Page with Zero-Lag IndexedStack & reactive language key
          SafeArea(
            bottom: false,
            child: IndexedStack(
              key: ValueKey(tn),
              index: _currentTab,
              children: const [
                DirectScannerView(),
                StatsScreen(),
                RewardsScreen(),
              ],
            ),
          ),

          // Floating Fast Apple Dock (Zero blur lag, warm sunset accents)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildAppleFloatingDock(tn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleFloatingDock(bool tn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppleColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DockItem(
            icon: CupertinoIcons.camera_viewfinder,
            label: tn ? 'صوّر' : 'Scan',
            isSelected: _currentTab == 0,
            onTap: () => setState(() => _currentTab = 0),
          ),
          const SizedBox(width: 4),
          _DockItem(
            icon: CupertinoIcons.chart_bar_alt_fill,
            label: tn ? 'البصمة' : 'Impact',
            isSelected: _currentTab == 1,
            onTap: () => setState(() => _currentTab = 1),
          ),
          const SizedBox(width: 4),
          _DockItem(
            icon: CupertinoIcons.rosette,
            label: tn ? 'الأوسمة' : 'Badges',
            isSelected: _currentTab == 2,
            onTap: () => setState(() => _currentTab = 2),
          ),
        ],
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppleColors.sunsetStart, AppleColors.sunsetEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x35FF8C00),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? Colors.white : AppleColors.tertiary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// DIRECT SCANNER VIEW: Camera-First, Instant Optical Access! (NO GALLERY ALLOWED)
class DirectScannerView extends StatefulWidget {
  const DirectScannerView({super.key});

  @override
  State<DirectScannerView> createState() => _DirectScannerViewState();
}

enum _ScannerStage { ready, analyzingBefore, cleaningPrompt, analyzingAfter, resultCelebration }

class _DirectScannerViewState extends State<DirectScannerView> {
  final ImagePicker _picker = ImagePicker();
  final ConfettiController _confetti = ConfettiController(duration: const Duration(seconds: 2));

  _ScannerStage _stage = _ScannerStage.ready;
  File? _beforeFile;
  File? _afterFile;
  ScanResult? _beforeResult;
  CleanupComparison? _comparison;
  String? _errorMessage;
  bool _noTrashFound = false;

  @override
  void initState() {
    super.initState();
    GameService.instance.addListener(_onGameUpdate);
  }

  @override
  void dispose() {
    GameService.instance.removeListener(_onGameUpdate);
    _confetti.dispose();
    super.dispose();
  }

  void _onGameUpdate() {
    if (mounted) setState(() {});
  }

  /// Strictly Live Camera Only - No Gallery Allowed
  Future<File?> _acquireCameraImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
    return picked != null ? File(picked.path) : null;
  }

  Future<void> _handleCaptureBefore() async {
    final file = await _acquireCameraImage();
    if (file == null) return;

    setState(() {
      _stage = _ScannerStage.analyzingBefore;
      _errorMessage = null;
      _noTrashFound = false;
    });

    try {
      final result = await DetectorService.instance.scan(file);
      if (!mounted) return;

      setState(() {
        if (result.detections.isEmpty) {
          _noTrashFound = true;
          _stage = _ScannerStage.ready;
        } else {
          _beforeFile = file;
          _beforeResult = result;
          _stage = _ScannerStage.cleaningPrompt;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '$e';
        _stage = _ScannerStage.ready;
      });
    }
  }

  Future<void> _handleCaptureAfter() async {
    final file = await _acquireCameraImage();
    if (file == null) return;

    setState(() {
      _stage = _ScannerStage.analyzingAfter;
      _errorMessage = null;
    });

    try {
      final result = await DetectorService.instance.scan(file);
      if (!mounted) return;

      // Intelligent spatial & visual matching between Before and After objects
      final comparison = CleanupComparison.evaluate(
        before: _beforeResult!.detections,
        after: result.detections,
      );

      setState(() {
        _afterFile = file;
        _comparison = comparison;
        _stage = _ScannerStage.resultCelebration;
      });

      if (comparison.score >= 80) {
        _confetti.play();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '$e';
        _stage = _ScannerStage.cleaningPrompt;
      });
    }
  }

  /// Assisted AI: Tap to add a target box if missed, or tap an existing box to remove it!
  void _handleTapOnPhoto(TapUpDetails details, BoxConstraints constraints) {
    if (_beforeResult == null) return;

    final localPos = details.localPosition;
    final normX = (localPos.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final normY = (localPos.dy / constraints.maxHeight).clamp(0.0, 1.0);
    final tapPoint = Offset(normX, normY);

    final currentDetections = List<DetectedObject>.from(_beforeResult!.detections);

    // Check if user tapped inside an existing box (to remove it)
    int tappedIndex = -1;
    for (int i = 0; i < currentDetections.length; i++) {
      if (currentDetections[i].box.inflate(0.02).contains(tapPoint)) {
        tappedIndex = i;
        break;
      }
    }

    if (tappedIndex != -1) {
      currentDetections.removeAt(tappedIndex);
    } else {
      // Add a target box at tap position (14% x 14% frame)
      const boxSize = 0.14;
      final newBox = Rect.fromCenter(
        center: tapPoint,
        width: boxSize,
        height: boxSize,
      );
      currentDetections.add(
        DetectedObject(
          box: newBox,
          confidence: 0.99, // User locked target
        ),
      );
    }

    setState(() {
      _beforeResult = ScanResult(
        detections: currentDetections,
        imageSize: _beforeResult!.imageSize,
      );
    });
  }

  int get _beforeCount => _beforeResult?.detections.length ?? 0;
  int get _cleanedCount => _comparison?.itemsCleaned ?? 0;
  int get _score => _comparison?.score ?? 0;

  void _finishQuest() {
    GameService.instance.recordCleanup(itemsCleaned: _cleanedCount, score: _score);
    _resetScanner();
  }

  void _resetScanner() {
    setState(() {
      _stage = _ScannerStage.ready;
      _beforeFile = null;
      _afterFile = null;
      _beforeResult = null;
      _comparison = null;
      _errorMessage = null;
      _noTrashFound = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = GameService.instance;
    final tn = game.isTunisian;

    return Stack(
      children: [
        Column(
          children: [
            // Top Apple Clean Header with Language Switcher & Goal Pill
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Title
                  Row(
                    children: [
                      const Icon(CupertinoIcons.viewfinder, size: 18, color: AppleColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        tn ? 'نظّف حومتك' : 'CLEAN YOUR STREET AI',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppleColors.ink,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Language Switcher (🇹🇳 TN / 🇬🇧 EN)
                      GestureDetector(
                        onTap: () => game.toggleLanguage(),
                        child: AppleGlassPill(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Text(
                            tn ? '🇹🇳 تونسي' : '🇬🇧 EN',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppleColors.ink,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Goal Progress Pill (Tap to setup goal!)
                      GestureDetector(
                        onTap: () => GoalSetupSheet.show(context),
                        child: AppleGlassPill(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          borderColor: game.isGoalCompleted ? AppleColors.green : AppleColors.border,
                          child: Row(
                            children: [
                              Icon(
                                game.isGoalCompleted ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.scope,
                                color: game.isGoalCompleted ? AppleColors.green : AppleColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${game.todayCleaned}/${game.dailyGoal}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: game.isGoalCompleted ? AppleColors.green : AppleColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // XP Pill
                      AppleGlassPill(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.sparkles, color: AppleColors.primary, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              '${game.availableXp} XP',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppleColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Interactive Stage
            Expanded(
              child: switch (_stage) {
                _ScannerStage.ready || _ScannerStage.analyzingBefore => _buildCameraFirstView(tn),
                _ScannerStage.cleaningPrompt || _ScannerStage.analyzingAfter => _buildCleaningView(tn),
                _ScannerStage.resultCelebration => _buildResultView(tn),
              },
            ),
          ],
        ),

        // Confetti celebration overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppleColors.primary,
              AppleColors.sunsetStart,
              AppleColors.green,
              AppleColors.blue,
            ],
          ),
        ),
      ],
    );
  }

  /// Camera-First Default Stage (Pure Camera Only - Warm Sunset Accents)
  Widget _buildCameraFirstView(bool tn) {
    final busy = _stage == _ScannerStage.analyzingBefore;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 84),
      child: Column(
        children: [
          // Viewfinder Container
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppleColors.border, width: 1.5),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Corner reticle painter
                    CustomPaint(painter: _ViewfinderCornersPainter()),

                    // Center scanner status
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (busy) ...[
                            const SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.5,
                                color: AppleColors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              tn ? 'قاعد يثبّت بالـ AI...' : 'Analyzing Image...',
                              style: const TextStyle(
                                color: AppleColors.ink,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tn ? 'كشف ذكي على المباشر' : 'Running on-device neural model',
                              style: const TextStyle(color: AppleColors.secondary, fontSize: 13),
                            ),
                          ] else ...[
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppleColors.sunsetStart.withAlpha(25),
                                border: Border.all(color: AppleColors.primary.withAlpha(100), width: 1.5),
                              ),
                              child: const Icon(
                                CupertinoIcons.camera_viewfinder,
                                color: AppleColors.primary,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              tn ? 'وجّه الكاميرا للوسخ وصوّر' : 'Aim at Litter & Snap Photo',
                              style: const TextStyle(
                                color: AppleColors.ink,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              tn ? 'الـ AI يثبّت في الدبابز، القراطس، والوسخ' : 'Live camera detects bottles, cans, paper, & debris',
                              style: const TextStyle(color: AppleColors.secondary, fontSize: 13),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (_noTrashFound)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: AppleGlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: const Color(0xFFFFFBEB),
                          borderColor: AppleColors.primary.withAlpha(80),
                          child: Text(
                            tn ? 'ما فماش وسخ في الزاوية هذي. قرّب أكثر!' : 'No litter recognized in that angle. Try stepping closer!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppleGlassCard(
                borderColor: Colors.redAccent.withAlpha(80),
                backgroundColor: const Color(0xFFFEF2F2),
                padding: const EdgeInsets.all(12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Camera Shutter Dock (Warm Yellowish-Orange Shutter)
          Stack(
            alignment: Alignment.center,
            children: [
              // Centered Big Apple Shutter Button
              AppleShutterButton(
                busy: busy,
                onPressed: _handleCaptureBefore,
              ),

              // Quick Reset Button on the right
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: busy ? null : _resetScanner,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppleColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(CupertinoIcons.arrow_counterclockwise, color: AppleColors.primary, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Clean Up Prompt View with Assisted AI (Warm Yellowish-Orange Button)
  Widget _buildCleaningView(bool tn) {
    final busy = _stage == _ScannerStage.analyzingAfter;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 84),
      child: Column(
        children: [
          // Detected photo with sharp reticles & Interactive Tap-to-Target
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: _beforeResult!.imageSize.width / _beforeResult!.imageSize.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapUp: (details) => _handleTapOnPhoto(details, constraints),
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_beforeFile!, fit: BoxFit.fill),
                            CustomPaint(painter: DetectionPainter(_beforeResult!.detections)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Assisted AI Helper Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.hand_point_left, size: 13, color: AppleColors.secondary),
              const SizedBox(width: 5),
              Text(
                tn ? 'انزل على الوسخ باش تزيدو • انزل على كادر باش تنحيه' : 'Tap missed litter to add box • Tap box to remove',
                style: TextStyle(fontSize: 11, color: AppleColors.secondary.withAlpha(200), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Clean instruction Apple card
          AppleGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppleColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppleColors.primary, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$_beforeCount',
                      style: const TextStyle(
                        color: AppleColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tn ? 'شلقنا بالوسخ! نضّف البلاصة' : 'Litter Locked. Clean the Spot!',
                        style: const TextStyle(
                          color: AppleColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tn ? 'لمّ الوسخ وطيشو، ومبعد عاود صوّر' : 'Pick up the items, then snap the camera to verify.',
                        style: const TextStyle(color: AppleColors.secondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action button (Warm Yellowish-Orange Sunset Gradient)
          GestureDetector(
            onTap: busy ? null : _handleCaptureAfter,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [AppleColors.sunsetStart, AppleColors.sunsetEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40FF6F00),
                    blurRadius: 16,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            tn ? 'ثبّت النظافة (صوّر توا)' : 'VERIFY CLEAN (SNAP CAMERA)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Results & Rewards Stage (Warm Yellowish-Orange Button)
  Widget _buildResultView(bool tn) {
    final comparison = _comparison;
    final remaining = comparison?.remainingItems.length ?? 0;
    final xp = GameService.xpFor(_cleanedCount, _score);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 95),
      children: [
        // Apple Score Ring
        Center(
          child: AppleScoreRing(
            progress: _score / 100,
            size: 140,
            stroke: 12,
            activeColor: _score >= 80 ? AppleColors.green : AppleColors.primary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_score%',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppleColors.ink,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _score >= 100
                      ? (tn ? 'تشعل شعيل' : 'SPOTLESS')
                      : (tn ? 'نظيفة' : 'VERIFIED'),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppleColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Mini Vitals Card
        AppleGlassCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ResultMetric(value: '$_cleanedCount', label: tn ? 'تنحّاو' : 'Cleaned'),
              Container(width: 1, height: 32, color: AppleColors.divider),
              _ResultMetric(value: '$remaining', label: tn ? 'مازالو' : 'Remaining'),
              Container(width: 1, height: 32, color: AppleColors.divider),
              _ResultMetric(
                value: '+$xp',
                label: tn ? 'نقاط' : 'XP Gained',
                accentColor: AppleColors.primary,
              ),
            ],
          ),
        ),

        // Helpful spatial matching note when new items are in frame
        if (comparison != null && comparison.newItems.isNotEmpty) ...[
          const SizedBox(height: 10),
          Center(
            child: Text(
              tn
                  ? 'ثمة ${comparison.newItems.length} قطايع جدد ظهروا ما حسبناهمش ضدك'
                  : '${comparison.newItems.length} new items detected nearby (not penalized in your cleanup)',
              style: const TextStyle(fontSize: 11, color: AppleColors.secondary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Interactive Curtain Scrubber
        BeforeAfterSlider(
          beforeImage: _beforeFile!,
          afterImage: _afterFile!,
          height: 270,
        ),
        const SizedBox(height: 20),

        // Social Media Story Button
        GestureDetector(
          onTap: () {
            if (_beforeFile != null && _afterFile != null && _comparison != null) {
              SocialShareModal.show(
                context,
                beforeImage: _beforeFile!,
                afterImage: _afterFile!,
                comparison: _comparison!,
                xp: xp,
              );
            }
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppleColors.primary.withAlpha(120)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10FF8C00),
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.share, color: AppleColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    tn ? 'بارطاجي فالستوري (INSTAGRAM)' : 'SHARE TO INSTAGRAM / STORY',
                    style: const TextStyle(
                      color: AppleColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Complete & Claim Button (Warm Sunset Gradient)
        GestureDetector(
          onTap: _finishQuest,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [AppleColors.sunsetStart, AppleColors.sunsetEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40FF6F00),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.sparkles, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    tn ? 'خوذ نقاطك ويعطيك الصحة' : 'CLAIM XP & COMPLETE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color? accentColor;

  const _ResultMetric({
    required this.value,
    required this.label,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: accentColor ?? AppleColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppleColors.secondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Viewfinder Corner Reticle Painter (Warm Sunset Hue)
class _ViewfinderCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const len = 22.0;
    final paint = Paint()
      ..color = AppleColors.primary.withAlpha(180)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-Left
    canvas.drawLine(const Offset(22, 22), const Offset(22 + len, 22), paint);
    canvas.drawLine(const Offset(22, 22), const Offset(22, 22 + len), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width - 22, 22), Offset(size.width - 22 - len, 22), paint);
    canvas.drawLine(Offset(size.width - 22, 22), Offset(size.width - 22, 22 + len), paint);

    // Bottom-Left
    canvas.drawLine(Offset(22, size.height - 22), Offset(22 + len, size.height - 22), paint);
    canvas.drawLine(Offset(22, size.height - 22), Offset(22, size.height - 22 - len), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width - 22, size.height - 22), Offset(size.width - 22 - len, size.height - 22), paint);
    canvas.drawLine(Offset(size.width - 22, size.height - 22), Offset(size.width - 22, size.height - 22 - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
