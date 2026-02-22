import 'package:flutter/material.dart';

import 'butter_chat_controller.dart';
import 'butter_chat_style.dart';
import 'models/butter_chat_message.dart';
import 'models/butter_chat_role.dart';
import 'models/butter_clarifying_question.dart';
import 'models/butter_suggestion.dart';
import 'widgets/butter_message_input.dart';
import 'widgets/butter_message_list.dart';
import 'widgets/butter_status_bar.dart';
import 'widgets/butter_typing_indicator.dart';
import 'widgets/butter_welcome_placeholder.dart';

/// Top-level chat widget that assembles the message list, input bar,
/// status indicators, and welcome placeholder.
///
/// The view accepts callbacks for user interactions — no LLM logic is
/// included. The consumer drives the conversation by interacting with
/// the [controller] in response to callbacks.
///
/// ```dart
/// ButterChatView(
///   controller: controller,
///   onSendMessage: (text) { /* start LLM call */ },
///   onStopGeneration: () { controller.stopStreaming(); },
///   onEditMessage: (id) { /* re-send with edit */ },
///   onRegenerateResponse: (id) { /* regenerate */ },
/// )
/// ```
class ButterChatView extends StatelessWidget {
  const ButterChatView({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.onStopGeneration,
    this.onEditMessage,
    this.onRegenerateResponse,
    this.onCopyMessage,
    this.onSubmitEdit,
    this.onContinueGeneration,
    this.style,
    this.markdownBuilder,
    this.codeBlockBuilder,
    this.welcomeBuilder,
    this.messageBubbleBuilder,
    this.messageHeaderBuilder,
    this.followUpBuilder,
    this.inputFocusNode,
    this.suggestions,
    this.onSuggestionTap,
    this.onQuestionAnswered,
    this.clarifyingQuestionBuilder,
  });

  /// The chat controller managing conversation state.
  final ButterChatController controller;

  /// Called when the user sends a message.
  final ValueChanged<String> onSendMessage;

  /// Called when the user stops generation.
  final VoidCallback? onStopGeneration;

  /// Called when the user edits a message. Receives the message ID.
  final ValueChanged<String>? onEditMessage;

  /// Called when the user regenerates a response. Receives the message ID.
  final ValueChanged<String>? onRegenerateResponse;

  /// Called when the user copies a message. Receives the message ID.
  final ValueChanged<String>? onCopyMessage;

  /// Called when the user saves an inline edit. Receives (id, newContent).
  final void Function(String id, String newContent)? onSubmitEdit;

  /// Called when the user taps continue on a stopped message.
  final ValueChanged<String>? onContinueGeneration;

  /// Style configuration (all optional, defaults from theme).
  final ButterChatStyle? style;

  /// Custom markdown renderer.
  final Widget Function(BuildContext context, String content)? markdownBuilder;

  /// Custom code block renderer.
  final Widget Function(BuildContext context, String code, String? language)?
      codeBlockBuilder;

  /// Custom welcome/empty state widget.
  final WidgetBuilder? welcomeBuilder;

  /// Wraps each message bubble for customization.
  final Widget Function(
          BuildContext context, ButterChatMessage message, Widget child)?
      messageBubbleBuilder;

  /// Custom header builder (e.g. model name label) above assistant content.
  final Widget Function(BuildContext context, ButterChatMessage message)?
      messageHeaderBuilder;

  /// Builder for follow-up suggestions below the last complete assistant message.
  final Widget Function(BuildContext context, ButterChatMessage message)?
      followUpBuilder;

  /// Optional focus node for the input field.
  final FocusNode? inputFocusNode;

  /// Suggestion prompts shown on the welcome screen.
  final List<ButterSuggestion>? suggestions;

  /// Called when a suggestion is tapped. Defaults to sending [ButterSuggestion.prompt].
  final ValueChanged<ButterSuggestion>? onSuggestionTap;

  /// Called when the user answers a clarifying question.
  /// Receives (messageId, selectedOptionIds, otherText).
  final void Function(
      String messageId, List<String> selectedIds, String? otherText)?
      onQuestionAnswered;

  /// Optional custom builder for clarifying question cards.
  final Widget Function(
          BuildContext context,
          ButterChatMessage message,
          ButterClarifyingQuestion question)?
      clarifyingQuestionBuilder;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = style?.resolve(context) ?? const ButterChatStyle();
    final maxWidth = resolvedStyle.maxContentWidth;

    return Container(
      color: resolvedStyle.backgroundColor,
      padding: resolvedStyle.padding,
      child: Column(
        children: [
          // Message list or welcome placeholder.
          Expanded(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final hasMessages = controller.activeMessages
                    .any((m) => m.role != ButterChatRole.system);

                if (!hasMessages) {
                  return welcomeBuilder?.call(context) ??
                      ButterWelcomePlaceholder(
                        suggestions: suggestions,
                        onSuggestionTap: onSuggestionTap ??
                            (s) => onSendMessage(s.prompt),
                        suggestionStyle: resolvedStyle.suggestionStyle,
                      );
                }

                return ButterMessageList(
                  controller: controller,
                  style: resolvedStyle,
                  onEditMessage: onEditMessage,
                  onRegenerateResponse: onRegenerateResponse,
                  onCopyMessage: onCopyMessage,
                  onSubmitEdit: onSubmitEdit,
                  onContinueGeneration: onContinueGeneration,
                  onQuestionAnswered: onQuestionAnswered,
                  markdownBuilder: markdownBuilder,
                  codeBlockBuilder: codeBlockBuilder,
                  messageBubbleBuilder: messageBubbleBuilder,
                  messageHeaderBuilder: messageHeaderBuilder,
                  followUpBuilder: followUpBuilder,
                  clarifyingQuestionBuilder: clarifyingQuestionBuilder,
                );
              },
            ),
          ),
          // Status bar and typing indicator.
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.statusLabel != null)
                    _centered(
                      maxWidth: maxWidth,
                      child: ButterStatusBar(
                        label: controller.statusLabel!,
                        style: resolvedStyle.statusBarStyle,
                      ),
                    ),
                  if (controller.isStreaming &&
                      controller.streamingMessage?.content.isEmpty == true)
                    _centered(
                      maxWidth: maxWidth,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ButterTypingIndicator(),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Input bar.
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return _centered(
                maxWidth: maxWidth,
                child: ButterMessageInput(
                  onSendMessage: onSendMessage,
                  onStopGeneration: onStopGeneration,
                  isStreaming: controller.isStreaming,
                  style: resolvedStyle.inputStyle,
                  focusNode: inputFocusNode,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Wraps [child] in Center > ConstrainedBox when maxWidth is set.
  Widget _centered({required double? maxWidth, required Widget child}) {
    if (maxWidth == null) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
