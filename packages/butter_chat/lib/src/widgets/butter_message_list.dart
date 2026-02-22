import 'package:flutter/material.dart';

import '../butter_chat_controller.dart';
import '../butter_chat_style.dart';
import '../models/butter_chat_message.dart';
import '../models/butter_chat_role.dart';
import '../models/butter_clarifying_question.dart';
import 'butter_message_bubble.dart';

/// Scrollable list of messages with auto-scroll and scroll-to-bottom button.
class ButterMessageList extends StatefulWidget {
  const ButterMessageList({
    super.key,
    required this.controller,
    this.style,
    this.onEditMessage,
    this.onRegenerateResponse,
    this.onCopyMessage,
    this.onSubmitEdit,
    this.onContinueGeneration,
    this.onQuestionAnswered,
    this.markdownBuilder,
    this.codeBlockBuilder,
    this.messageBubbleBuilder,
    this.messageHeaderBuilder,
    this.followUpBuilder,
    this.clarifyingQuestionBuilder,
  });

  final ButterChatController controller;
  final ButterChatStyle? style;
  final ValueChanged<String>? onEditMessage;
  final ValueChanged<String>? onRegenerateResponse;
  final ValueChanged<String>? onCopyMessage;
  final void Function(String id, String newContent)? onSubmitEdit;
  final ValueChanged<String>? onContinueGeneration;
  final void Function(
      String messageId, List<String> selectedIds, String? otherText)?
      onQuestionAnswered;
  final Widget Function(BuildContext context, String content)? markdownBuilder;
  final Widget Function(BuildContext context, String code, String? language)?
      codeBlockBuilder;
  final Widget Function(
          BuildContext context, ButterChatMessage message, Widget child)?
      messageBubbleBuilder;
  final Widget Function(BuildContext context, ButterChatMessage message)?
      messageHeaderBuilder;
  final Widget Function(BuildContext context, ButterChatMessage message)?
      followUpBuilder;
  final Widget Function(
          BuildContext context,
          ButterChatMessage message,
          ButterClarifyingQuestion question)?
      clarifyingQuestionBuilder;

  @override
  State<ButterMessageList> createState() => _ButterMessageListState();
}

class _ButterMessageListState extends State<ButterMessageList> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = true;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(ButterMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  void _onScroll() {
    final atBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50;
    if (atBottom != _isAtBottom) {
      setState(() => _isAtBottom = atBottom);
    }
  }

  void _onControllerChanged() {
    final messages = widget.controller.activeMessages;
    // Auto-scroll when new messages arrive or content is streaming.
    if (_isAtBottom && messages.length >= _lastMessageCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
    _lastMessageCount = messages.length;
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    widget.controller.removeListener(_onControllerChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = widget.style?.maxContentWidth;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final messages = widget.controller.activeMessages
            .where((m) => m.role != ButterChatRole.system)
            .toList();
        final spacing = widget.style?.messageSpacing ?? 16.0;

        return Stack(
          children: [
            ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: messages.length,
              separatorBuilder: (_, __) => SizedBox(height: spacing),
              itemBuilder: (context, index) {
                final message = messages[index];
                final isLast = index == messages.length - 1;
                final bubble = ButterMessageBubble(
                  message: message,
                  controller: widget.controller,
                  style: widget.style,
                  onEdit: widget.onEditMessage,
                  onRegenerate: widget.onRegenerateResponse,
                  onCopy: widget.onCopyMessage,
                  onSubmitEdit: widget.onSubmitEdit,
                  onContinueGeneration: widget.onContinueGeneration,
                  onQuestionAnswered: widget.onQuestionAnswered,
                  markdownBuilder: widget.markdownBuilder,
                  codeBlockBuilder: widget.codeBlockBuilder,
                  messageHeaderBuilder: widget.messageHeaderBuilder,
                  followUpBuilder: widget.followUpBuilder,
                  clarifyingQuestionBuilder:
                      widget.clarifyingQuestionBuilder,
                  isLastMessage: isLast,
                );

                Widget child = bubble;
                if (widget.messageBubbleBuilder != null) {
                  child =
                      widget.messageBubbleBuilder!(context, message, bubble);
                }

                // Center with max-width constraint.
                if (maxWidth != null) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: child,
                    ),
                  );
                }
                return child;
              },
            ),
            // Scroll-to-bottom button (centered circle).
            if (!_isAtBottom)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Material(
                    shape: const CircleBorder(),
                    elevation: 2,
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: InkWell(
                      onTap: _scrollToBottom,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
