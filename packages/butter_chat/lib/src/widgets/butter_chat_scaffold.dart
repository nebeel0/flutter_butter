import 'package:flutter/material.dart';

import '../butter_chat_controller.dart';
import '../butter_chat_style.dart';
import '../butter_chat_view.dart';
import '../models/butter_chat_message.dart';
import '../models/butter_chat_session.dart';
import '../models/butter_clarifying_question.dart';
import '../models/butter_suggestion.dart';
import 'butter_side_panel.dart';

/// Responsive layout combining a [ButterSidePanel] and [ButterChatView].
///
/// Above [breakpoint] width, the side panel is shown persistently in a [Row].
/// Below [breakpoint], the side panel is accessible as a [Drawer].
class ButterChatScaffold extends StatelessWidget {
  const ButterChatScaffold({
    super.key,
    // Side panel params.
    required this.sessions,
    this.activeSessionId,
    required this.onSessionTap,
    this.onNewChat,
    this.onDeleteSession,
    this.onRenameSession,
    this.onPinSession,
    this.onSearchChanged,
    this.sessionBuilder,
    this.sidePanelHeaderBuilder,
    this.sidePanelFooterBuilder,
    this.sidePanelStyle,
    this.showSearch = true,
    // Chat view params.
    required this.controller,
    required this.onSendMessage,
    this.onStopGeneration,
    this.onEditMessage,
    this.onRegenerateResponse,
    this.onCopyMessage,
    this.onSubmitEdit,
    this.onContinueGeneration,
    this.onQuestionAnswered,
    this.style,
    this.markdownBuilder,
    this.codeBlockBuilder,
    this.welcomeBuilder,
    this.messageBubbleBuilder,
    this.messageHeaderBuilder,
    this.followUpBuilder,
    this.clarifyingQuestionBuilder,
    this.inputFocusNode,
    this.suggestions,
    this.onSuggestionTap,
    // Layout params.
    this.breakpoint = 768.0,
    this.sidePanelWidth = 280.0,
    this.scaffoldKey,
  });

  // --- Side panel ---
  final List<ButterChatSession> sessions;
  final String? activeSessionId;
  final ValueChanged<ButterChatSession> onSessionTap;
  final VoidCallback? onNewChat;
  final ValueChanged<ButterChatSession>? onDeleteSession;
  final void Function(ButterChatSession session, String newTitle)?
      onRenameSession;
  final ValueChanged<ButterChatSession>? onPinSession;
  final ValueChanged<String>? onSearchChanged;
  final Widget Function(
          BuildContext context, ButterChatSession session, bool isActive)?
      sessionBuilder;
  final WidgetBuilder? sidePanelHeaderBuilder;
  final WidgetBuilder? sidePanelFooterBuilder;
  final ButterSidePanelStyle? sidePanelStyle;
  final bool showSearch;

  // --- Chat view ---
  final ButterChatController controller;
  final ValueChanged<String> onSendMessage;
  final VoidCallback? onStopGeneration;
  final ValueChanged<String>? onEditMessage;
  final ValueChanged<String>? onRegenerateResponse;
  final ValueChanged<String>? onCopyMessage;
  final void Function(String id, String newContent)? onSubmitEdit;
  final ValueChanged<String>? onContinueGeneration;
  final void Function(
      String messageId, List<String> selectedIds, String? otherText)?
      onQuestionAnswered;
  final ButterChatStyle? style;
  final Widget Function(BuildContext context, String content)? markdownBuilder;
  final Widget Function(BuildContext context, String code, String? language)?
      codeBlockBuilder;
  final WidgetBuilder? welcomeBuilder;
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
  final FocusNode? inputFocusNode;
  final List<ButterSuggestion>? suggestions;
  final ValueChanged<ButterSuggestion>? onSuggestionTap;

  // --- Layout ---

  /// Width breakpoint for switching between persistent panel and drawer.
  /// Defaults to 768.0.
  final double breakpoint;

  /// Width of the side panel. Defaults to 280.0.
  final double sidePanelWidth;

  /// Optional scaffold key for controlling the drawer programmatically.
  final GlobalKey<ScaffoldState>? scaffoldKey;

  Widget _buildSidePanel() {
    return ButterSidePanel(
      sessions: sessions,
      activeSessionId: activeSessionId,
      onSessionTap: onSessionTap,
      onNewChat: onNewChat,
      onDeleteSession: onDeleteSession,
      onRenameSession: onRenameSession,
      onPinSession: onPinSession,
      onSearchChanged: onSearchChanged,
      sessionBuilder: sessionBuilder,
      headerBuilder: sidePanelHeaderBuilder,
      footerBuilder: sidePanelFooterBuilder,
      style: sidePanelStyle,
      showSearch: showSearch,
    );
  }

  Widget _buildChatView() {
    return ButterChatView(
      controller: controller,
      onSendMessage: onSendMessage,
      onStopGeneration: onStopGeneration,
      onEditMessage: onEditMessage,
      onRegenerateResponse: onRegenerateResponse,
      onCopyMessage: onCopyMessage,
      onSubmitEdit: onSubmitEdit,
      onContinueGeneration: onContinueGeneration,
      onQuestionAnswered: onQuestionAnswered,
      style: style,
      markdownBuilder: markdownBuilder,
      codeBlockBuilder: codeBlockBuilder,
      welcomeBuilder: welcomeBuilder,
      messageBubbleBuilder: messageBubbleBuilder,
      messageHeaderBuilder: messageHeaderBuilder,
      followUpBuilder: followUpBuilder,
      clarifyingQuestionBuilder: clarifyingQuestionBuilder,
      inputFocusNode: inputFocusNode,
      suggestions: suggestions,
      onSuggestionTap: onSuggestionTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= breakpoint;

        if (isWide) {
          // Desktop: persistent side panel in a Row.
          final dividerColor =
              sidePanelStyle?.dividerColor ??
              Theme.of(context).colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  );
          return Row(
            children: [
              SizedBox(
                width: sidePanelWidth,
                child: _buildSidePanel(),
              ),
              VerticalDivider(width: 1, color: dividerColor),
              Expanded(child: _buildChatView()),
            ],
          );
        }

        // Mobile: drawer-based layout.
        return Scaffold(
          key: scaffoldKey,
          drawer: SizedBox(
            width: sidePanelWidth,
            child: Drawer(child: _buildSidePanel()),
          ),
          body: _buildChatView(),
        );
      },
    );
  }
}
