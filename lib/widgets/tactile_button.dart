import 'package:flutter/material.dart';

class TactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color shadowColor;
  final Color textColor;
  final double height;
  final double depth;
  final BorderRadius borderRadius;

  const TactileButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFE85D04),
    this.shadowColor = const Color(0xFF9D0208),
    this.textColor = Colors.white,
    this.height = 54,
    this.depth = 5,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double currentOffset = _isPressed ? widget.depth : 0.0;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        if (_isPressed) {
          setState(() => _isPressed = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        height: widget.height,
        margin: EdgeInsets.only(top: currentOffset, bottom: widget.depth - currentOffset),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius,
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: Offset(0, widget.depth),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              color: widget.textColor,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
