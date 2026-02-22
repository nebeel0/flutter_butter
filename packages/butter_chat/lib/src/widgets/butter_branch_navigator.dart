import 'package:flutter/material.dart';

import '../butter_chat_style.dart';

/// Branch navigation arrows (< 2/3 >) for navigating between message branches.
class ButterBranchNavigator extends StatelessWidget {
  const ButterBranchNavigator({
    super.key,
    required this.currentIndex,
    required this.totalBranches,
    required this.onPrevious,
    required this.onNext,
    this.style,
  });

  /// Zero-based index of the current branch.
  final int currentIndex;

  /// Total number of branches.
  final int totalBranches;

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ButterBranchNavigatorStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = style?.iconColor ?? colorScheme.onSurfaceVariant;
    final iconSize = style?.iconSize ?? 16.0;
    final textStyle = style?.textStyle ??
        theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, size: iconSize, color: iconColor),
          onPressed: currentIndex > 0 ? onPrevious : null,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          tooltip: 'Previous branch',
        ),
        Text(
          '${currentIndex + 1}/$totalBranches',
          style: textStyle,
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, size: iconSize, color: iconColor),
          onPressed: currentIndex < totalBranches - 1 ? onNext : null,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          tooltip: 'Next branch',
        ),
      ],
    );
  }
}
