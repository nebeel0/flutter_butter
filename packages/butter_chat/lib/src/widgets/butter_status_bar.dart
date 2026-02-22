import 'package:flutter/material.dart';

import '../butter_chat_style.dart';

/// Displays a status label (e.g. "Searching...", "Analyzing...").
class ButterStatusBar extends StatelessWidget {
  const ButterStatusBar({
    super.key,
    required this.label,
    this.style,
  });

  final String label;
  final ButterStatusBarStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: style?.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: style?.iconColor ?? colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: style?.textStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
