import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/detection.dart';
import '../services/detector_service.dart';
import '../services/game_service.dart';
import '../widgets/before_after_slider.dart';
import '../widgets/rubber_stamp.dart';
import '../widgets/surveyor_reticle_painter.dart';
import '../widgets/tactile_button.dart';

enum QuestStep { beforePhoto, cleaningInProgress, summary }

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  final ImagePicker _picker = ImagePicker();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  QuestStep _currentStep = QuestStep.beforePhoto;
  bool _isProcessing = false;

  File? _beforeImage;
  File? _afterImage;
  List<DetectedObject> _beforeDetections = [];
  List<DetectedObject> _afterDetections = [];
  QuestResult? _result;

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto(bool isBefore) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );

    if (pickedFile == null) return;
    await _processImage(File(pickedFile.path), isBefore);
  }

  Future<void> _pickFromGallery(bool isBefore) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
    );

    if (pickedFile == null) return;
    await _processImage(File(pickedFile.path), isBefore);
  }

  Future<void> _processImage(File file, bool isBefore) async {
    setState(() => _isProcessing = true);

    final detections = await DetectorService.instance.detectTrash(
      file,
      isAfterCleaning: !isBefore,
    );

    setState(() {
      _isProcessing = false;
      if (isBefore) {
        _beforeImage = file;
        _beforeDetections = detections;
        _currentStep = QuestStep.cleaningInProgress;
      } else {
        _afterImage = file;
        _afterDetections = detections;
        _currentStep = QuestStep.summary;

        _result = GameService.instance.completeQuest(
          beforeImagePath: _beforeImage!.path,
          afterImagePath: _afterImage!.path,
          beforeDetections: _beforeDetections,
          afterDetections: _afterDetections,
        );
        _confettiController.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111714),
      appBar: AppBar(
        backgroundColor: const Color(0xFF19231D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFEBE5D8), size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          switch (_currentStep) {
            QuestStep.beforePhoto => 'RECON // SITE SCAN',
            QuestStep.cleaningInProgress => 'PATROL // RECLAMATION',
            QuestStep.summary => 'DISPATCH // AUDIT REPORT',
          },
          style: const TextStyle(
            color: Color(0xFFEBE5D8),
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontFamily: 'monospace',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: const Color(0xFF2C3E34), height: 1.5),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: _isProcessing
                ? _buildProcessingHUD()
                : switch (_currentStep) {
                    QuestStep.beforePhoto => _buildBeforePhotoPrompt(),
                    QuestStep.cleaningInProgress => _buildCleaningInProgressView(),
                    QuestStep.summary => _buildSummaryView(),
                  },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFF55A630),
                Color(0xFFE85D04),
                Color(0xFFF48C06),
                Color(0xFF2A9D8F),
                Color(0xFFEBE5D8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingHUD() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF19231D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2C3E34), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Color(0xFFE85D04),
                strokeWidth: 3.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'OPTICAL NEURAL SCAN',
              style: TextStyle(
                color: Color(0xFFEBE5D8),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DetectorService.instance.isModelLoaded
                  ? 'ON-DEVICE YOLOv8 INFERENCE IN PROGRESS'
                  : 'EMULATING FIELD SCANNER HARDWARE',
              style: const TextStyle(
                color: Color(0xFF809B8B),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeforePhotoPrompt() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rangefinder Target Icon
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF19231D),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE85D04), width: 2.5),
            ),
            child: const Center(
              child: Icon(Icons.filter_center_focus_rounded, size: 56, color: Color(0xFFE85D04)),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'LOG CONTAMINATED SECTOR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFFEBE5D8),
              letterSpacing: 1.2,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Point camera directly at ground litter or waste. Ensure good lighting and keep the frame steady.',
            style: TextStyle(fontSize: 13, color: Color(0xFF809B8B), height: 1.45),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          TactileButton(
            backgroundColor: const Color(0xFFE85D04),
            shadowColor: const Color(0xFF9D0208),
            onPressed: () => _takePhoto(true),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('CAPTURE BEFORE SPECIMEN', style: TextStyle(fontFamily: 'monospace')),
              ],
            ),
          ),
          const SizedBox(height: 14),

          TactileButton(
            backgroundColor: const Color(0xFF19231D),
            shadowColor: const Color(0xFF0C130F),
            textColor: const Color(0xFFEBE5D8),
            onPressed: () => _pickFromGallery(true),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, color: Color(0xFF809B8B), size: 20),
                SizedBox(width: 10),
                Text('SELECT FROM DISK ARCHIVE', style: TextStyle(fontFamily: 'monospace', fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleaningInProgressView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Telemetry status strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF19231D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2C3E34)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.crisis_alert_rounded, color: Color(0xFFF48C06), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${_beforeDetections.length} SPECIMENS CLASSIFIED',
                      style: const TextStyle(
                        color: Color(0xFFEBE5D8),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const Text(
                  'SECTOR DIRTY',
                  style: TextStyle(
                    color: Color(0xFFD00000),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tactical HUD Viewfinder Photo Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2C3E34), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_beforeImage!, fit: BoxFit.cover),
                  CustomPaint(
                    painter: SurveyorReticlePainter(detections: _beforeDetections),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Specimen Inventory List
          const Text(
            'DETECTED CONTAMINANTS IN AREA:',
            style: TextStyle(
              color: Color(0xFF809B8B),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),

          Column(
            children: _beforeDetections.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final d = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF19231D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2C3E34)),
                ),
                child: Row(
                  children: [
                    Text(
                      '#$idx',
                      style: const TextStyle(
                        color: Color(0xFFF48C06),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        d.label.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFEBE5D8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Text(
                      '${(d.confidence * 100).toInt()}% CONF',
                      style: const TextStyle(
                        color: Color(0xFF809B8B),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Mission Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withAlpha(35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF55A630).withAlpha(120)),
            ),
            child: const Row(
              children: [
                Icon(Icons.cleaning_services, color: Color(0xFF55A630), size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Clear all tagged specimens from the ground. Then tap below to audit the cleaned sector.',
                    style: TextStyle(
                      color: Color(0xFFEBE5D8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          TactileButton(
            backgroundColor: const Color(0xFF2D6A4F),
            shadowColor: const Color(0xFF1B4332),
            onPressed: () => _takePhoto(false),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text('AUDIT SECTOR (AFTER PHOTO)', style: TextStyle(fontFamily: 'monospace')),
              ],
            ),
          ),
          const SizedBox(height: 10),

          TactileButton(
            backgroundColor: const Color(0xFF19231D),
            shadowColor: const Color(0xFF0C130F),
            textColor: const Color(0xFFEBE5D8),
            onPressed: () => _pickFromGallery(false),
            child: const Text('PICK AFTER PHOTO FROM DISK', style: TextStyle(fontFamily: 'monospace', fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryView() {
    final result = _result;
    if (result == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Animated Certified Ink Stamp
          Center(
            child: RubberStamp(
              text: result.cleanlinessScore >= 90 ? '★ SECTOR RESTORED ★' : 'PARTIAL RECLAMATION',
              subText: '${result.cleanlinessScore.toInt()}% AUDIT SCORE // CERTIFIED BY AI',
              color: result.cleanlinessScore >= 90 ? const Color(0xFF55A630) : const Color(0xFFF48C06),
            ),
          ),
          const SizedBox(height: 24),

          // Interactive Draggable Curtain Wipe Slider
          const Text(
            'INTERACTIVE RECLAMATION SCRUBBER (DRAG HANDLE):',
            style: TextStyle(
              color: Color(0xFF809B8B),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),

          BeforeAfterSlider(
            beforeImage: _beforeImage!,
            afterImage: _afterImage!,
            height: 280,
          ),
          const SizedBox(height: 20),

          // Salvage Metrics Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF19231D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2C3E34)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'SALVAGE YIELD',
                          style: TextStyle(
                            color: Color(0xFF809B8B),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${result.xpEarned} XP',
                          style: const TextStyle(
                            color: Color(0xFFF48C06),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 38, color: const Color(0xFF2C3E34)),
                    Column(
                      children: [
                        const Text(
                          'WASTE RECLAIMED',
                          style: TextStyle(
                            color: Color(0xFF809B8B),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.itemsCleaned} ITEMS',
                          style: const TextStyle(
                            color: Color(0xFF55A630),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          TactileButton(
            backgroundColor: const Color(0xFFE85D04),
            shadowColor: const Color(0xFF9D0208),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE REPORT // RETURN TO BASE', style: TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
