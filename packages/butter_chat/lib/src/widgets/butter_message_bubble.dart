import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../butter_chat_controller.dart';
import '../butter_chat_style.dart';
import '../models/butter_chat_message.dart';
import '../models/butter_chat_message_status.dart';
import '../models/butter_chat_role.dart';
import '../models/butter_clarifying_question.dart';
import 'butter_branch_navigator.dart';
import 'butter_clarifying_question_card.dart';
import 'butter_markdown_content.dart';
import 'butter_message_actions.dart';
import 'butter_plan_indicator.dart';
import 'butter_status_timeline.dart';

/// Renders a single message with Open WebUI-style layout:
/// - Assistant: full-width, no background, content flows naturally
/// - User: right-aligned with subtle rounded background
/// - Actions appear on hover (always shown on last message)
class ButterMessageBubble extends StatefulWidget {
  const ButterMessageBubble({
    super.key,
    required this.message,
    required this.controller,
    this.style,
    this.onEdit,
    this.onRegenerate,
    this.onCopy,
    this.onSubmitEdit,
    this.onContinueGeneration,
    this.onQuestionAnswered,
    this.markdownBuilder,
    this.codeBlockBuilder,
    this.messageHeaderBuilder,
    this.followUpBuilder,
    this.clarifyingQuestionBuilder,
    this.isLastMessage = false,
  });

  final ButterChatMessage message;
  final ButterChatController controller;
  final ButterChatStyle? style;
  final ValueChanged<String>? onEdit;
  final ValueChanged<String>? onRegenerate;
  final ValueChanged<String>? onCopy;

  /// Called when the user saves an inline edit. Receives (id, newContent).
  final void Function(String id, String newContent)? onSubmitEdit;

  /// Called when the user taps continue on a stopped message.
  final ValueChanged<String>? onContinueGeneration;

  /// Called when the user answers a clarifying question.
  final void Function(
      String messageId, List<String> selectedIds, String? otherText)?
      onQuestionAnswered;

  final Widget Function(BuildContext context, String content)? markdownBuilder;
  final Widget Function(BuildContext context, String code, String? language)?
      codeBlockBuilder;

  /// Custom header builder (e.g. model name label) above assistant content.
  final Widget Function(BuildContext context, ButterChatMessage message)?
      messageHeaderBuilder;

  /// Builder for follow-up suggestions below the last complete assistant message.
  final Widget Function(BuildContext context, ButterChatMessage message)?
      followUpBuilder;

  /// Optional custom builder for clarifying question cards.
  final Widget Function(
          BuildContext context,
          ButterChatMessage message,
          ButterClarifyingQuestion question)?
      clarifyingQuestionBuilder;

  final bool isLastMessage;

  @override
  State<ButterMessageBubble> createState() => _ButterMessageBubbleState();
}

class _ButterMessageBubbleState extends State<ButterMessageBubble> {
  bool _isHovered = false;
  bool _isEditing = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.message.content);
  }

  @override
  void didUpdateWidget(ButterMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.content != widget.message.content && !_isEditing) {
      _editController.text = widget.message.content;
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _editController.text = widget.message.content;
    });
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
  }

  void _submitEdit() {
    final newContent = _editController.text.trim();
    if (newContent.isNotEmpty && newContent != widget.message.content) {
      widget.onSubmitEdit?.call(widget.message.id, newContent);
    }
    setState(() => _isEditing = false);
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final msgStyle = widget.style?.messageStyle;
    final isUser = widget.message.role == ButterChatRole.user;

    // Branch navigation.
    final parentId = widget.message.parentId;
    final parent =
        parentId != null ? widget.controller.messages[parentId] : null;
    final showBranchNav = parent != null && parent.childIds.length > 1;
    final branchIndex =
        showBranchNav ? parent.childIds.indexOf(widget.message.id) : 0;

    final branchNavigator = showBranchNav
        ? ButterBranchNavigator(
            currentIndex: branchIndex,
            totalBranches: parent.childIds.length,
            onPrevious: () => widget.controller.switchBranch(
              parentId!,
              parent.activeChildIndex - 1,
            ),
            onNext: () => widget.controller.switchBranch(
              parentId!,
              parent.activeChildIndex + 1,
            ),
            style: widget.style?.branchNavigatorStyle,
          )
        : null;

    final showActions = widget.message.status ==
            ButterChatMessageStatus.complete ||
        widget.message.status == ButterChatMessageStatus.stopped;
    final actionsVisible = showActions && (_isHovered || widget.isLastMessage);

    // Show continue button only on stopped assistant messages that are the last message.
    final showContinue = !isUser &&
        widget.message.status == ButterChatMessageStatus.stopped &&
        widget.isLastMessage &&
        widget.onContinueGeneration != null;

    // Always build actions when the message status allows it, but control
    // visibility via opacity to prevent layout shifts on hover.
    final actions = showActions
        ? ButterMessageActions(
            role: widget.message.role,
            branchNavigator: branchNavigator,
            onCopy: widget.onCopy != null
                ? () => widget.onCopy!(widget.message.id)
                : () => Clipboard.setData(
                      ClipboardData(text: widget.message.content),
                    ),
            onEdit: isUser && widget.onSubmitEdit != null
                ? _startEditing
                : widget.onEdit != null
                    ? () => widget.onEdit!(widget.message.id)
                    : null,
            onRegenerate: widget.onRegenerate != null
                ? () => widget.onRegenerate!(widget.message.id)
                : null,
            onContinue: showContinue
                ? () => widget.onContinueGeneration!(widget.message.id)
                : null,
            style: widget.style?.actionStyle,
          )
        : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: isUser
          ? _buildUserMessage(colorScheme, msgStyle, actions, actionsVisible)
          : _buildAssistantMessage(
              colorScheme, msgStyle, actions, actionsVisible),
    );
  }

  Widget _buildAssistantMessage(
    ColorScheme colorScheme,
    ButterMessageStyle? msgStyle,
    Widget? actions,
    bool actionsVisible,
  ) {
    final theme = Theme.of(context);
    final fgColor =
        msgStyle?.assistantForegroundColor ?? colorScheme.onSurface;
    final bgColor = msgStyle?.assistantBackgroundColor;
    final padding = msgStyle?.assistantPadding ??
        const EdgeInsets.symmetric(vertical: 4);
    final showTimestamps = msgStyle?.showTimestamps ?? true;
    final avatarBuilder = msgStyle?.avatarBuilder;

    // Status timeline (only for messages with >1 labeled status entry).
    final labeledEntries = widget.message.statusHistory
        .where((e) => e.label != null)
        .toList();
    final showTimeline = labeledEntries.length > 1;

    Widget contentColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Message header (custom builder or timestamp on hover).
        if (widget.messageHeaderBuilder != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: widget.messageHeaderBuilder!(context, widget.message),
          )
        else if (showTimestamps)
          AnimatedOpacity(
            opacity: _isHovered ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _formatRelativeTime(widget.message.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ),
          ),
        // Status timeline.
        if (showTimeline)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ButterStatusTimeline(
              statusHistory: widget.message.statusHistory,
              isComplete: widget.message.status ==
                  ButterChatMessageStatus.complete,
            ),
          ),
        // Thinking indicator.
        if (widget.message.thinkingContent.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ButterPlanIndicator(
              content: widget.message.thinkingContent,
              status: widget.message.status,
              style: widget.style?.planIndicatorStyle,
            ),
          ),
        // Message content.
        if (widget.message.content.isNotEmpty)
          DefaultTextStyle.merge(
            style: TextStyle(color: fgColor),
            child: widget.markdownBuilder != null
                ? widget.markdownBuilder!(context, widget.message.content)
                : ButterMarkdownContent(
                    content: widget.message.content,
                    style: TextStyle(color: fgColor),
                    codeBlockBuilder: widget.codeBlockBuilder,
                  ),
          ),
        // Clarifying question card.
        if (widget.message.clarifyingQuestion != null)
          Padding(
            padding: EdgeInsets.only(
                top: widget.message.content.isNotEmpty ? 12 : 0),
            child: _buildClarifyingQuestion(widget.message.clarifyingQuestion!),
          ),
      ],
    );

    // Wrap with avatar if builder provided.
    Widget body;
    if (avatarBuilder != null) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: avatarBuilder(context, false),
          ),
          const SizedBox(width: 12),
          Expanded(child: contentColumn),
        ],
      );
    } else {
      body = contentColumn;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration:
              bgColor != null ? BoxDecoration(color: bgColor) : null,
          padding: padding,
          child: body,
        ),
        if (actions != null)
          AnimatedOpacity(
            opacity: actionsVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: IgnorePointer(
              ignoring: !actionsVisible,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 4,
                  left: avatarBuilder != null ? 44.0 : 0.0,
                ),
                child: actions,
              ),
            ),
          ),
        // Follow-up builder (below actions on last complete assistant message).
        if (widget.followUpBuilder != null &&
            widget.isLastMessage &&
            widget.message.status == ButterChatMessageStatus.complete)
          Padding(
            padding: EdgeInsets.only(
              top: 8,
              left: avatarBuilder != null ? 44.0 : 0.0,
            ),
            child: widget.followUpBuilder!(context, widget.message),
          ),
      ],
    );
  }

  Widget _buildUserMessage(
    ColorScheme colorScheme,
    ButterMessageStyle? msgStyle,
    Widget? actions,
    bool actionsVisible,
  ) {
    final bgColor =
        msgStyle?.userBackgroundColor ?? colorScheme.surfaceContainerHighest;
    final fgColor = msgStyle?.userForegroundColor ?? colorScheme.onSurface;
    final radius = msgStyle?.userBorderRadius ?? BorderRadius.circular(24);
    final padding = msgStyle?.userPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    if (_isEditing) {
      return _buildEditingMode(colorScheme, radius);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: radius,
              ),
              padding: padding,
              child: DefaultTextStyle.merge(
                style: TextStyle(color: fgColor),
                child: Text(widget.message.content),
              ),
            ),
          ),
        ),
        if (actions != null)
          AnimatedOpacity(
            opacity: actionsVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: IgnorePointer(
              ignoring: !actionsVisible,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: actions,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildClarifyingQuestion(ButterClarifyingQuestion question) {
    if (widget.clarifyingQuestionBuilder != null) {
      return widget.clarifyingQuestionBuilder!(
          context, widget.message, question);
    }
    return ButterClarifyingQuestionCard(
      question: question,
      style: widget.style?.clarifyingQuestionStyle,
      onSubmit: (selectedIds, otherText) {
        widget.onQuestionAnswered?.call(
          widget.message.id,
          selectedIds,
          otherText,
        );
      },
    );
  }

  Widget _buildEditingMode(ColorScheme colorScheme, BorderRadius radius) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _editController,
                maxLines: null,
                minLines: 1,
                autofocus: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: _cancelEditing,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submitEdit,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.onSurface,
                      foregroundColor: colorScheme.surface,
                    ),
                    child: const Text('Save & Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
