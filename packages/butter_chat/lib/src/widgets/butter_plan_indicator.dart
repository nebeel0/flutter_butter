import 'package:flutter/material.dart';

import '../butter_chat_style.dart';
import '../models/butter_chat_message_status.dart';

/// A collapsible section that shows thinking/plan content.
///
/// Auto-expands when the message status is [ButterChatMessageStatus.thinking]
/// and can be manually toggled by the user.
class ButterPlanIndicator extends StatefulWidget {
  const ButterPlanIndicator({
    super.key,
    required this.content,
    required this.status,
    this.style,
  });

  final String content;
  final ButterChatMessageStatus status;
  final ButterPlanIndicatorStyle? style;

  @override
  State<ButterPlanIndicator> createState() => _ButterPlanIndicatorState();
}

class _ButterPlanIndicatorState extends State<ButterPlanIndicator>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expanded = widget.status == ButterChatMessageStatus.thinking;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (_expanded) _animationController.value = 1.0;
  }

  @override
  void didUpdateWidget(ButterPlanIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-expand when thinking starts.
    if (widget.status == ButterChatMessageStatus.thinking &&
        oldWidget.status != ButterChatMessageStatus.thinking) {
      _setExpanded(true);
    }
    // Auto-collapse when thinking ends (unless user manually opened it).
    if (oldWidget.status == ButterChatMessageStatus.thinking &&
        widget.status != ButterChatMessageStatus.thinking) {
      _setExpanded(false);
    }
  }

  void _setExpanded(bool expanded) {
    setState(() => _expanded = expanded);
    if (expanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = widget.style;

    final isThinking = widget.status == ButterChatMessageStatus.thinking;

    return Container(
      decoration: BoxDecoration(
        color: style?.backgroundColor ??
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: style?.borderRadius ?? BorderRadius.circular(8),
        border: Border.all(
          color: style?.border?.color ??
              colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: style?.border?.width ?? 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — tap to toggle.
          InkWell(
            onTap: () => _setExpanded(!_expanded),
            borderRadius: style?.borderRadius ?? BorderRadius.circular(8),
            child: Padding(
              padding: style?.padding ??
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (isThinking)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: style?.iconColor ?? colorScheme.primary,
                      ),
                    )
                  else
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: style?.iconColor ?? colorScheme.primary,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    isThinking ? 'Thinking...' : 'Thought process',
                    style: style?.labelStyle ??
                        theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                    child: Icon(
                      Icons.expand_more,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content — animated expand/collapse.
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: SelectableText(
                widget.content,
                style: style?.contentStyle ??
                    theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
