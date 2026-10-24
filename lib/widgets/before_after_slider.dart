import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import 'glass.dart';

class BeforeAfterSlider extends StatefulWidget {
  final File beforeImage;
  final File afterImage;
  final double height;

  const BeforeAfterSlider({
    super.key,
    required this.beforeImage,
    required this.afterImage,
    this.height = 300,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _split = 0.5;

  Widget _pillTag(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final x = w * _split;
      final tn = GameService.instance.isTunisian;

      void drag(double dx) =>
          setState(() => _split = (_split + dx / w).clamp(0.04, 0.96));

      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: w,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppleColors.border, width: 1.5),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) => drag(d.delta.dx),
            onTapDown: (d) =>
                setState(() => _split = (d.localPosition.dx / w).clamp(0.04, 0.96)),
            child: Stack(
              children: [
                // Clean Image (After)
                Positioned.fill(
                  child: Image.file(widget.afterImage, fit: BoxFit.cover),
                ),
                // Contaminated Image (Before)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: x,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.centerLeft,
                      minWidth: w,
                      maxWidth: w,
                      child: SizedBox(
                        width: w,
                        height: widget.height,
                        child: Image.file(widget.beforeImage, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                Positioned(top: 14, left: 14, child: _pillTag(tn ? 'قبل' : 'BEFORE', AppleColors.primary)),
                Positioned(top: 14, right: 14, child: _pillTag(tn ? 'من بعد' : 'AFTER', AppleColors.green)),
                // Divider line
                Positioned(
                  left: x - 1.5,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    color: Colors.white,
                  ),
                ),
                // Draggable Handle
                Positioned(
                  left: x - 22,
                  top: widget.height / 2 - 22,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x30000000),
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_left_right,
                      color: AppleColors.ink,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
