import 'package:flutter/material.dart';

/// An animated button that scales down on press and back up on release.
class SmoothButton extends StatefulWidget {
  const SmoothButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 150),
  });

  /// Callback when the button is tapped.
  final VoidCallback onPressed;

  /// The widget displayed inside the button.
  final Widget child;

  /// Background color. Defaults to the theme's primary color.
  final Color? color;

  /// Corner radius of the button.
  final double borderRadius;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Scale factor when pressed (1.0 = no scale, 0.9 = 10% smaller).
  final double scaleFactor;

  /// Duration of the press animation.
  final Duration duration;

  @override
  State<SmoothButton> createState() => _SmoothButtonState();
}

class _SmoothButtonState extends State<SmoothButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: ThemeData.estimateBrightnessForColor(bgColor) ==
                      Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
