import 'package:flutter/material.dart';

import '../butter_chat_style.dart';
import '../models/butter_chat_session.dart';

/// A single session tile for the side panel.
///
/// Displays the session title, optional subtitle, relative timestamp,
/// and supports active/hover highlighting and context menu actions.
class ButterSessionTile extends StatefulWidget {
  const ButterSessionTile({
    super.key,
    required this.session,
    this.isActive = false,
    this.onTap,
    this.onDelete,
    this.onRename,
    this.onPin,
    this.style,
  });

  final ButterChatSession session;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onRename;
  final VoidCallback? onPin;
  final ButterSessionTileStyle? style;

  @override
  State<ButterSessionTile> createState() => _ButterSessionTileState();
}

class _ButterSessionTileState extends State<ButterSessionTile> {
  bool _isHovered = false;

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  void _showContextMenu(Offset position) {
    final items = <PopupMenuEntry<String>>[];
    if (widget.onPin != null) {
      items.add(PopupMenuItem(
        value: 'pin',
        child: Row(
          children: [
            Icon(
              widget.session.isPinned
                  ? Icons.push_pin
                  : Icons.push_pin_outlined,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(widget.session.isPinned ? 'Unpin' : 'Pin'),
          ],
        ),
      ));
    }
    if (widget.onRename != null) {
      items.add(const PopupMenuItem(
        value: 'rename',
        child: Row(
          children: [
            Icon(Icons.edit_outlined, size: 18),
            SizedBox(width: 8),
            Text('Rename'),
          ],
        ),
      ));
    }
    if (widget.onDelete != null) {
      items.add(const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline, size: 18),
            SizedBox(width: 8),
            Text('Delete'),
          ],
        ),
      ));
    }

    if (items.isEmpty) return;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: items,
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'pin':
          widget.onPin?.call();
        case 'rename':
          _showRenameDialog();
        case 'delete':
          widget.onDelete?.call();
      }
    });
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: widget.session.title);
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename chat'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    ).then((newName) {
      controller.dispose();
      if (newName != null && newName.trim().isNotEmpty) {
        widget.onRename?.call(newName.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = widget.style;

    final activeBg =
        style?.activeBackgroundColor ?? colorScheme.surfaceContainerHighest;
    final hoverBg =
        style?.hoverBackgroundColor ?? colorScheme.surfaceContainerHigh;
    final borderRadius = style?.borderRadius ?? BorderRadius.circular(8);
    final padding = style?.padding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    final titleStyle = style?.titleStyle ??
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    final subtitleStyle = style?.subtitleStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );
    final timestampStyle = style?.timestampStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 11,
        );

    Color? bgColor;
    if (widget.isActive) {
      bgColor = activeBg;
    } else if (_isHovered) {
      bgColor = hoverBg;
    }

    final timestamp = widget.session.updatedAt ?? widget.session.createdAt;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onSecondaryTapUp: (details) =>
            _showContextMenu(details.globalPosition),
        onLongPressStart: (details) =>
            _showContextMenu(details.globalPosition),
        child: Material(
          color: bgColor ?? Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: padding,
              child: Row(
                children: [
                  if (widget.session.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.push_pin,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.session.title,
                          style: titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.session.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.session.subtitle!,
                              style: subtitleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (timestamp != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        _formatRelativeTime(timestamp),
                        style: timestampStyle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
