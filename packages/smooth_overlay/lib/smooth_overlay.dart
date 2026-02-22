import 'package:flutter/material.dart';

/// A dismissible card overlay with a close button, optional hint, and actions.
///
/// Use for floating previews, popovers, or any card that needs a close button
/// overlaid on its content.
class SmoothOverlayCard extends StatelessWidget {
  /// The main content of the card.
  final Widget child;

  /// Called when the close button is tapped.
  final VoidCallback onClose;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  /// Fixed width. If null, sizes to content.
  final double? width;

  /// Fixed height for the content area (not including hint).
  final double? height;

  /// Optional hint text displayed below the content.
  final String? hintText;

  /// Icon displayed next to the hint text.
  final IconData? hintIcon;

  /// Additional action widgets displayed next to the close button.
  final List<Widget>? actions;

  /// Corner radius of the card.
  final double borderRadius;

  /// Shadow blur radius.
  final double shadowBlurRadius;

  /// Shadow offset.
  final Offset shadowOffset;

  /// Background color of the card.
  final Color backgroundColor;

  const SmoothOverlayCard({
    super.key,
    required this.child,
    required this.onClose,
    this.onTap,
    this.width,
    this.height,
    this.hintText,
    this.hintIcon,
    this.actions,
    this.borderRadius = 12,
    this.shadowBlurRadius = 12,
    this.shadowOffset = const Offset(0, 4),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: shadowBlurRadius,
              offset: shadowOffset,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Content with close button overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius),
                    bottom: hintText != null
                        ? Radius.zero
                        : Radius.circular(borderRadius),
                  ),
                  child: SizedBox(height: height, child: child),
                ),
                // Action buttons and close button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (actions != null) ...actions!,
                      Material(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          onTap: onClose,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Optional hint at bottom
            if (hintText != null)
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(borderRadius),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    if (hintIcon != null) ...[
                      Icon(
                        hintIcon,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      hintText!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
