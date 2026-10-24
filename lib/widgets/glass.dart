import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppleColors {
  static const canvas = Color(0xFFF5F6F8);
  static const card = Colors.white;
  static const ink = Color(0xFF1D1D1F);
  static const secondary = Color(0xFF6E6E73);
  static const tertiary = Color(0xFF86868B);
  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFEEEEF0);

  // Warm Yellowish-Orange Energetic Palette (Replacing cold black)
  static const primary = Color(0xFFFF8C00); // Vibrant Tangerine
  static const sunsetStart = Color(0xFFFFB300); // Warm Golden Amber
  static const sunsetEnd = Color(0xFFFF6F00); // Deep Sunset Orange

  static const green = Color(0xFF34C759);
  static const blue = Color(0xFF007AFF);
  static const orange = Color(0xFFFF9500);
  static const purple = Color(0xFFAF52DE);
}

/// Lightweight, ultra-smooth Apple canvas (zero GPU lag).
class AppleCanvasBackground extends StatelessWidget {
  final Widget child;
  const AppleCanvasBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppleColors.canvas,
      child: child,
    );
  }
}

/// High-performance Apple frosted-style card with crisp borders and soft shadows.
class AppleGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const AppleGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);

    Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppleColors.card,
        borderRadius: br,
        border: Border.all(
          color: borderColor ?? AppleColors.border,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }
    return card;
  }
}

/// Clean floating pill.
class AppleGlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  const AppleGlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor ?? AppleColors.border,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// High-performance camera shutter button with warm sunset glow.
class AppleShutterButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool busy;

  const AppleShutterButton({
    super.key,
    required this.onPressed,
    this.busy = false,
  });

  @override
  State<AppleShutterButton> createState() => _AppleShutterButtonState();
}

class _AppleShutterButtonState extends State<AppleShutterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.busy) widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: AppleColors.sunsetStart.withAlpha(80),
              width: 4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28FF8C00),
                blurRadius: 22,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.busy
                ? const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppleColors.primary,
                    ),
                  )
                : Container(
                    width: 62,
                    height: 62,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppleColors.sunsetStart, AppleColors.sunsetEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x40FF6F00),
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Smooth progress ring with clean contrast.
class AppleScoreRing extends StatelessWidget {
  final double progress;
  final double size;
  final double stroke;
  final Widget child;
  final Color activeColor;

  const AppleScoreRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 110,
    this.stroke = 10,
    this.activeColor = AppleColors.green,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AppleRingPainter(
        progress.clamp(0.0, 1.0),
        stroke,
        activeColor,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

class _AppleRingPainter extends CustomPainter {
  final double progress;
  final double stroke;
  final Color activeColor;

  _AppleRingPainter(this.progress, this.stroke, this.activeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppleColors.canvas,
    );

    if (progress <= 0) return;

    // Active arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = activeColor,
    );
  }

  @override
  bool shouldRepaint(covariant _AppleRingPainter old) =>
      old.progress != progress || old.stroke != stroke || old.activeColor != activeColor;
}
