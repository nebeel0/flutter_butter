import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../butter_chat_style.dart';

/// Chat input bar with Open WebUI-style layout: rounded container with
/// the send/stop button inside, Shift+Enter for newlines.
class ButterMessageInput extends StatefulWidget {
  const ButterMessageInput({
    super.key,
    required this.onSendMessage,
    this.onStopGeneration,
    this.isStreaming = false,
    this.style,
    this.focusNode,
  });

  final ValueChanged<String> onSendMessage;
  final VoidCallback? onStopGeneration;
  final bool isStreaming;
  final ButterInputStyle? style;
  final FocusNode? focusNode;

  @override
  State<ButterMessageInput> createState() => _ButterMessageInputState();
}

class _ButterMessageInputState extends State<ButterMessageInput> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage(text);
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final inputStyle = widget.style;
    final useBlur = inputStyle?.useBackdropBlur ?? true;

    final bgColor = inputStyle?.backgroundColor ??
        (useBlur
            ? colorScheme.surfaceContainerLow.withValues(alpha: 0.8)
            : colorScheme.surfaceContainerLow);
    final radius = inputStyle?.borderRadius ?? BorderRadius.circular(24);
    final border =
        inputStyle?.border ?? BorderSide(color: colorScheme.outlineVariant);
    final hintText = inputStyle?.hintText ?? 'Type a message...';
    final maxLines = inputStyle?.maxLines ?? 6;
    final elevation = inputStyle?.elevation ?? 2.0;

    // Send button: high-contrast black/white depending on brightness.
    final isDark = colorScheme.brightness == Brightness.dark;
    final sendBgEnabled =
        inputStyle?.sendButtonColor ?? colorScheme.onSurface;
    final sendFgEnabled = isDark ? Colors.black : Colors.white;
    final sendBgDisabled = colorScheme.onSurface.withValues(alpha: 0.12);
    final sendFgDisabled = colorScheme.onSurface.withValues(alpha: 0.38);

    Widget container = Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        border: Border.all(
          color: border.color,
          width: border.width,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text field (no border — border is on outer container).
          KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.enter &&
                  !HardwareKeyboard.instance.isShiftPressed) {
                _handleSend();
              }
            },
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: maxLines,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              style: inputStyle?.textStyle,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: inputStyle?.hintStyle,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Bottom bar with send/stop button.
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.isStreaming)
                  _CircularActionButton(
                    onPressed: widget.onStopGeneration,
                    icon: Icons.stop,
                    backgroundColor: inputStyle?.stopButtonColor ??
                        colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    tooltip: 'Stop generation',
                  )
                else
                  _CircularActionButton(
                    onPressed: _hasText ? _handleSend : null,
                    icon: Icons.arrow_upward,
                    backgroundColor:
                        _hasText ? sendBgEnabled : sendBgDisabled,
                    foregroundColor:
                        _hasText ? sendFgEnabled : sendFgDisabled,
                    tooltip: 'Send message',
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (useBlur) {
      container = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: container,
        ),
      );
    }

    return Padding(
      padding: inputStyle?.padding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: container,
    );
  }
}

class _CircularActionButton extends StatelessWidget {
  const _CircularActionButton({
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, size: 18, color: foregroundColor),
          ),
        ),
      ),
    );
  }
}
