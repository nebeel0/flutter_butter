import 'dart:async';

import 'package:flutter/material.dart';

import '../butter_chat_style.dart';
import '../models/butter_chat_role.dart';

/// Action buttons displayed below a message (copy, edit, regenerate, continue)
/// with an optional leading branch navigator widget.
class ButterMessageActions extends StatefulWidget {
  const ButterMessageActions({
    super.key,
    required this.role,
    this.branchNavigator,
    this.onCopy,
    this.onEdit,
    this.onRegenerate,
    this.onContinue,
    this.style,
  });

  final ButterChatRole role;

  /// Optional branch navigator widget rendered at the start of the actions row.
  final Widget? branchNavigator;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onRegenerate;

  /// Called when the user taps "Continue generation" on a stopped assistant message.
  final VoidCallback? onContinue;
  final ButterActionStyle? style;

  @override
  State<ButterMessageActions> createState() => _ButterMessageActionsState();
}

class _ButterMessageActionsState extends State<ButterMessageActions> {
  bool _copiedRecently = false;
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  void _handleCopy() {
    widget.onCopy?.call();
    setState(() => _copiedRecently = true);
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedRecently = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor =
        widget.style?.iconColor ?? colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    final iconSize = widget.style?.iconSize ?? 16.0;
    final spacing = widget.style?.spacing ?? 4.0;
    final hoverBgColor = widget.style?.hoverBackgroundColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.branchNavigator != null) ...[
          widget.branchNavigator!,
          SizedBox(width: spacing),
        ],
        if (widget.onCopy != null)
          _ActionButton(
            icon: _copiedRecently ? Icons.check : Icons.copy,
            tooltip: _copiedRecently ? 'Copied!' : 'Copy',
            onPressed: _handleCopy,
            iconColor: _copiedRecently
                ? colorScheme.primary
                : iconColor,
            iconSize: iconSize,
            hoverBackgroundColor: hoverBgColor,
          ),
        if (widget.role == ButterChatRole.user && widget.onEdit != null) ...[
          SizedBox(width: spacing),
          _ActionButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit',
            onPressed: widget.onEdit!,
            iconColor: iconColor,
            iconSize: iconSize,
            hoverBackgroundColor: hoverBgColor,
          ),
        ],
        if (widget.role == ButterChatRole.assistant &&
            widget.onRegenerate != null) ...[
          SizedBox(width: spacing),
          _ActionButton(
            icon: Icons.refresh,
            tooltip: 'Regenerate',
            onPressed: widget.onRegenerate!,
            iconColor: iconColor,
            iconSize: iconSize,
            hoverBackgroundColor: hoverBgColor,
          ),
        ],
        if (widget.role == ButterChatRole.assistant &&
            widget.onContinue != null) ...[
          SizedBox(width: spacing),
          _ActionButton(
            icon: Icons.arrow_forward,
            tooltip: 'Continue generation',
            onPressed: widget.onContinue!,
            iconColor: iconColor,
            iconSize: iconSize,
            hoverBackgroundColor: hoverBgColor,
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.iconColor,
    required this.iconSize,
    this.hoverBackgroundColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color iconColor;
  final double iconSize;
  final Color? hoverBackgroundColor;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hoverBg = widget.hoverBackgroundColor ??
        colorScheme.onSurface.withValues(alpha: 0.05);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _isHovered ? hoverBg : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon,
                  key: ValueKey(widget.icon),
                  size: widget.iconSize,
                  color: widget.iconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
