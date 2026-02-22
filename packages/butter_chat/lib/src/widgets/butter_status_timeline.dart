import 'package:flutter/material.dart';

import '../models/butter_chat_message_status.dart';

/// Collapsible vertical timeline showing a message's status history.
///
/// Displays a collapsed summary (last label + chevron) that expands to
/// show all timestamped status entries with connecting dots and lines.
class ButterStatusTimeline extends StatefulWidget {
  const ButterStatusTimeline({
    super.key,
    required this.statusHistory,
    this.isComplete = false,
  });

  final List<ButterChatStatusEntry> statusHistory;

  /// Whether the message is complete (auto-collapses when true).
  final bool isComplete;

  @override
  State<ButterStatusTimeline> createState() => _ButterStatusTimelineState();
}

class _ButterStatusTimelineState extends State<ButterStatusTimeline> {
  bool _expanded = false;

  @override
  void didUpdateWidget(ButterStatusTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-collapse when message completes.
    if (widget.isComplete && !oldWidget.isComplete) {
      _expanded = false;
    }
  }

  /// Entries that have a human-readable label.
  List<ButterChatStatusEntry> get _labeledEntries =>
      widget.statusHistory.where((e) => e.label != null).toList();

  @override
  Widget build(BuildContext context) {
    final entries = _labeledEntries;
    if (entries.length < 2) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    final dotColor = colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Collapsed header.
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: dotColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entries.last.label!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 16,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Expanded timeline.
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 3, top: 4, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  _TimelineEntry(
                    label: entries[i].label!,
                    timestamp: entries[i].timestamp,
                    dotColor: dotColor,
                    mutedColor: mutedColor,
                  ),
                  if (i < entries.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: SizedBox(
                        height: 16,
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: mutedColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.label,
    required this.timestamp,
    required this.dotColor,
    required this.mutedColor,
  });

  final String label;
  final DateTime timestamp;
  final Color dotColor;
  final Color mutedColor;

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    return '$h:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 6, color: dotColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
        ),
        const SizedBox(width: 12),
        Text(
          _formatTime(timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: mutedColor.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
