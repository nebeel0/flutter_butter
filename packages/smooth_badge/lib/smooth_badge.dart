import 'package:flutter/material.dart';

/// A colored pill badge for displaying status indicators, tags, or labels.
///
/// Automatically picks a contrasting text color based on the background
/// brightness using [ThemeData.estimateBrightnessForColor].
class SmoothBadge extends StatelessWidget {
  /// The text displayed in the badge.
  final String text;

  /// Optional smaller label below the main text.
  final String? label;

  /// Background color of the badge.
  final Color color;

  /// Text color. If null, auto-selects white or black based on [color] brightness.
  final Color? textColor;

  /// Font size of the main text.
  final double fontSize;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Corner radius of the pill shape.
  final double borderRadius;

  const SmoothBadge({
    super.key,
    required this.text,
    this.label,
    this.color = Colors.grey,
    this.textColor,
    this.fontSize = 13,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.borderRadius = 8,
  });

  /// Creates a badge with a predefined status color.
  factory SmoothBadge.status({
    required String text,
    required SmoothBadgeStatus status,
    String? label,
    double fontSize = 13,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    double borderRadius = 8,
  }) {
    return SmoothBadge(
      text: text,
      label: label,
      color: status.color,
      fontSize: fontSize,
      padding: padding,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTextColor = textColor ?? _autoTextColor(color);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: label != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: resolvedTextColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label!,
                  style: TextStyle(
                    color: resolvedTextColor.withValues(alpha: 0.85),
                    fontSize: 10,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Text(
              text,
              style: TextStyle(
                color: resolvedTextColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  static Color _autoTextColor(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }
}

/// Predefined status types for [SmoothBadge.status].
enum SmoothBadgeStatus {
  success(Colors.green),
  warning(Colors.orange),
  error(Colors.red),
  info(Colors.blue);

  final Color color;
  const SmoothBadgeStatus(this.color);
}
