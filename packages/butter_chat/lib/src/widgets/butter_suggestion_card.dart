import 'package:flutter/material.dart';

import '../butter_chat_style.dart';
import '../models/butter_suggestion.dart';

/// Tappable suggestion prompt card with title and optional subtitle.
class ButterSuggestionCard extends StatefulWidget {
  const ButterSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onTap,
    this.style,
  });

  final ButterSuggestion suggestion;
  final VoidCallback onTap;
  final ButterSuggestionStyle? style;

  @override
  State<ButterSuggestionCard> createState() => _ButterSuggestionCardState();
}

class _ButterSuggestionCardState extends State<ButterSuggestionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = widget.style?.backgroundColor ??
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final hoverBg = colorScheme.onSurface.withValues(alpha: 0.05);
    final radius =
        widget.style?.borderRadius ?? BorderRadius.circular(16);
    final padding = widget.style?.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final titleStyle = widget.style?.textStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        );
    final subtitleStyle = widget.style?.subtitleStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered ? hoverBg : bgColor,
            borderRadius: radius,
          ),
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.suggestion.title, style: titleStyle),
              if (widget.suggestion.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(widget.suggestion.subtitle!, style: subtitleStyle),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
