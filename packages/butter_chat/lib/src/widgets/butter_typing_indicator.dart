import 'package:flutter/material.dart';

/// Animated dots indicating the assistant is preparing to respond.
class ButterTypingIndicator extends StatefulWidget {
  const ButterTypingIndicator({super.key, this.color, this.dotSize = 6.0});

  final Color? color;
  final double dotSize;

  @override
  State<ButterTypingIndicator> createState() => _ButterTypingIndicatorState();
}

class _ButterTypingIndicatorState extends State<ButterTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Stagger the animation for each dot.
            final delay = index * 0.2;
            final value =
                ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            // Sine wave for smooth bounce.
            final offset = (value < 0.5)
                ? -4.0 * (0.5 - (value - 0.25).abs() * 4).clamp(0.0, 1.0)
                : 0.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.3),
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.4 + value * 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
