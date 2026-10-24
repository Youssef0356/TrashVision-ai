import 'dart:io';
import 'package:flutter/material.dart';

class BeforeAfterSlider extends StatefulWidget {
  final File beforeImage;
  final File afterImage;
  final double height;

  const BeforeAfterSlider({
    super.key,
    required this.beforeImage,
    required this.afterImage,
    this.height = 320,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _splitFraction = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final splitPos = totalWidth * _splitFraction;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: widget.height,
            width: totalWidth,
            color: Colors.black,
            child: Stack(
              children: [
                // "After" (Clean) Image in background
                Positioned.fill(
                  child: Image.file(
                    widget.afterImage,
                    fit: BoxFit.cover,
                  ),
                ),

                // "Before" (Dirty) Image clipped by the divider fraction
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  width: splitPos.clamp(0.0, totalWidth),
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.centerLeft,
                      minWidth: totalWidth,
                      maxWidth: totalWidth,
                      minHeight: widget.height,
                      maxHeight: widget.height,
                      child: Image.file(
                        widget.beforeImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // "DIRTY" badge on left
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD00000).withAlpha(220),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'BEFORE / CONTAMINATED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                // "RESTORED" badge on right
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D6A4F).withAlpha(220),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'AFTER / RESTORED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                // Draggable vertical divider bar
                Positioned(
                  left: splitPos - 1.5,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    color: Colors.white,
                  ),
                ),

                // Draggable handle knob in the middle
                Positioned(
                  left: splitPos - 22,
                  top: (widget.height / 2) - 22,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _splitFraction = (_splitFraction + (details.delta.dx / totalWidth))
                            .clamp(0.02, 0.98);
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE85D04),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.drag_indicator_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),

                // Tap detector across whole surface for instant slider reposition
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _splitFraction = (_splitFraction + (details.delta.dx / totalWidth))
                            .clamp(0.02, 0.98);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
