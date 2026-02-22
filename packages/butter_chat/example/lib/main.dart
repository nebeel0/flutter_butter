import 'dart:async';
import 'dart:math';

import 'package:butter_chat/butter_chat.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ButterChatExampleApp());
}

class ButterChatExampleApp extends StatelessWidget {
  const ButterChatExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ButterChat Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Map<String, ButterChatController> _controllers = {};
  String _activeSessionId = 'session_0';
  int _nextId = 0;
  int _nextSessionId = 1;
  StreamSubscription<void>? _streamSubscription;

  final List<ButterChatSession> _sessions = [
    ButterChatSession(
      id: 'session_0',
      title: 'Welcome Chat',
      subtitle: 'Getting started with ButterChat',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ButterChatSession(
      id: 'session_demo_1',
      title: 'Flutter Architecture',
      subtitle: 'Discussing state management',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ButterChatSession(
      id: 'session_demo_2',
      title: 'API Integration',
      subtitle: 'REST vs GraphQL',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      isPinned: true,
    ),
  ];

  ButterChatController get _controller {
    return _controllers.putIfAbsent(
      _activeSessionId,
      () => ButterChatController(),
    );
  }

  String _generateId() => 'msg_${_nextId++}';

  @override
  void dispose() {
    _streamSubscription?.cancel();
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSendMessage(String text) async {
    final userMsgId = _generateId();
    _controller.addUserMessage(id: userMsgId, content: text);

    // Check if the message should trigger a clarifying question.
    if (text.toLowerCase().contains('plan') ||
        text.toLowerCase().contains('help me choose')) {
      await _simulateClarifyingQuestion(userMsgId, text);
      return;
    }

    final assistantMsgId = _generateId();
    _controller.addAssistantMessage(id: assistantMsgId, parentId: userMsgId);
    await _simulateStreaming(assistantMsgId, text);
  }

  Future<void> _simulateClarifyingQuestion(
      String userMsgId, String userText) async {
    // Short delay to simulate thinking.
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final questionMsgId = _generateId();
    _controller.addClarifyingQuestion(
      id: questionMsgId,
      parentId: userMsgId,
      content: 'Before I help you with that, I have a few questions:',
      question: const ButterClarifyingQuestion(
        questionText: 'What type of project are you working on?',
        options: [
          ButterQuestionOption(
            id: 'mobile',
            label: 'Mobile App',
            description: 'iOS or Android using Flutter',
          ),
          ButterQuestionOption(
            id: 'web',
            label: 'Web App',
            description: 'Browser-based Flutter application',
          ),
          ButterQuestionOption(
            id: 'desktop',
            label: 'Desktop App',
            description: 'macOS, Windows, or Linux',
          ),
          ButterQuestionOption(
            id: 'package',
            label: 'Package/Library',
            description: 'Reusable Dart/Flutter package',
          ),
        ],
        allowOther: true,
      ),
    );
  }

  void _handleQuestionAnswered(
      String messageId, List<String> selectedIds, String? otherText) {
    // Resolve the question in the controller.
    _controller.resolveClarifyingQuestion(
      messageId,
      selectedOptionIds: selectedIds,
      otherText: otherText,
    );

    // Generate a follow-up response based on the answer.
    final assistantMsgId = _generateId();
    _controller.addAssistantMessage(id: assistantMsgId, parentId: messageId);

    final answers = selectedIds.join(', ');
    final extra = otherText != null ? ' (also: $otherText)' : '';
    _simulateStreaming(
      assistantMsgId,
      'follow-up for $answers$extra',
    );
  }

  Future<void> _handleEditMessage(String id) async {
    final original = _controller.messages[id];
    if (original == null) return;

    final newId = _generateId();
    _controller.editUserMessage(
      id,
      '[Edited] ${original.content}',
      newId: newId,
    );

    final assistantMsgId = _generateId();
    _controller.addAssistantMessage(id: assistantMsgId, parentId: newId);
    await _simulateStreaming(assistantMsgId, '[Edited] ${original.content}');
  }

  void _handleSubmitEdit(String id, String newContent) {
    final newId = _generateId();
    _controller.editUserMessage(id, newContent, newId: newId);

    final assistantMsgId = _generateId();
    _controller.addAssistantMessage(id: assistantMsgId, parentId: newId);
    _simulateStreaming(assistantMsgId, newContent);
  }

  Future<void> _handleRegenerateResponse(String id) async {
    final newId = _generateId();
    _controller.regenerateResponse(id, newId: newId);
    await _simulateStreaming(newId, 'regenerated');
  }

  Future<void> _handleContinueGeneration(String id) async {
    _controller.setMessageStatus(id, ButterChatMessageStatus.streaming);

    const continuation =
        '\n\n---\n\n*Continuing generation...* Here is some additional content '
        'that demonstrates the **continue** feature. In a real app, this would '
        'resume the LLM generation from where it left off.';

    final words = continuation.split(' ');
    for (var i = 0; i < words.length; i++) {
      await Future<void>.delayed(
          Duration(milliseconds: 20 + Random().nextInt(30)));
      if (_controller.messages[id]?.status ==
          ButterChatMessageStatus.stopped) {
        return;
      }
      final token = i == 0 ? words[i] : ' ${words[i]}';
      _controller.appendContent(id, token);
    }

    _controller.setMessageStatus(id, ButterChatMessageStatus.complete);
  }

  void _handleStopGeneration() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _controller.stopStreaming();
  }

  void _handleNewChat() {
    final sessionId = 'session_${_nextSessionId++}';
    setState(() {
      _sessions.insert(
        0,
        ButterChatSession(
          id: sessionId,
          title: 'New Chat',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      _activeSessionId = sessionId;
    });
  }

  void _handleSessionTap(ButterChatSession session) {
    setState(() => _activeSessionId = session.id);
  }

  void _handleDeleteSession(ButterChatSession session) {
    setState(() {
      _sessions.removeWhere((s) => s.id == session.id);
      _controllers[session.id]?.dispose();
      _controllers.remove(session.id);
      if (_activeSessionId == session.id && _sessions.isNotEmpty) {
        _activeSessionId = _sessions.first.id;
      }
    });
  }

  void _handleRenameSession(ButterChatSession session, String newTitle) {
    setState(() {
      final index = _sessions.indexWhere((s) => s.id == session.id);
      if (index >= 0) {
        _sessions[index] = session.copyWith(title: newTitle);
      }
    });
  }

  void _handlePinSession(ButterChatSession session) {
    setState(() {
      final index = _sessions.indexWhere((s) => s.id == session.id);
      if (index >= 0) {
        _sessions[index] = session.copyWith(isPinned: !session.isPinned);
      }
    });
  }

  Future<void> _simulateStreaming(String messageId, String userText) async {
    _controller.setMessageStatus(
      messageId,
      ButterChatMessageStatus.thinking,
      label: 'Thinking...',
    );
    _controller.setStatusLabel('Analyzing...');

    final thinkingText = _generateThinkingText(userText);
    for (final char in thinkingText.split('')) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (_controller.messages[messageId]?.status ==
          ButterChatMessageStatus.stopped) {
        return;
      }
      _controller.appendThinkingContent(messageId, char);
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_controller.messages[messageId]?.status ==
        ButterChatMessageStatus.stopped) {
      return;
    }

    _controller.setMessageStatus(
      messageId,
      ButterChatMessageStatus.streaming,
      label: 'Searching the web...',
    );

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (_controller.messages[messageId]?.status ==
        ButterChatMessageStatus.stopped) {
      return;
    }

    _controller.setMessageStatus(
      messageId,
      ButterChatMessageStatus.streaming,
      label: 'Analyzed 3 sources',
    );
    _controller.setStatusLabel(null);

    final response = _generateResponse(userText);
    final words = response.split(' ');

    for (var i = 0; i < words.length; i++) {
      await Future<void>.delayed(
          Duration(milliseconds: 20 + Random().nextInt(30)));
      if (_controller.messages[messageId]?.status ==
          ButterChatMessageStatus.stopped) {
        return;
      }
      final token = i == 0 ? words[i] : ' ${words[i]}';
      _controller.appendContent(messageId, token);
    }

    _controller.setMessageStatus(
        messageId, ButterChatMessageStatus.complete);
    _controller.setStatusLabel(null);
  }

  String _generateThinkingText(String userText) {
    return 'Let me think about "$userText"...\n'
        'I should consider the context and provide a helpful response.\n'
        'Breaking down the key points to address.';
  }

  String _generateResponse(String userText) {
    final lower = userText.toLowerCase();

    if (lower.contains('follow-up for')) {
      return 'Great choice! Based on your selection, I recommend:\n\n'
          '1. **Start with a clean architecture** using feature-based folders\n'
          '2. **Use Riverpod** for state management\n'
          '3. **Set up CI/CD** early with GitHub Actions\n\n'
          'Would you like me to create a project template for you?';
    }

    if (lower.contains('code') || lower.contains('example')) {
      return 'Here\'s a simple example:\n\n'
          '```dart\nvoid main() {\n  print(\'Hello from ButterChat!\');\n}\n```\n\n'
          'This demonstrates basic Dart syntax. You can modify it to suit your needs.';
    }

    if (lower.contains('hello') || lower.contains('hi')) {
      return 'Hello! I\'m a simulated AI assistant powered by **ButterChat**. '
          'I can demonstrate:\n\n'
          '- **Streaming** responses token by token\n'
          '- **Thinking/plan** mode with collapsible sections\n'
          '- **Message branching** via edit and regenerate\n'
          '- **Clarifying questions** with selectable options\n'
          '- **Side panel** with session management\n\n'
          'Try saying "help me choose a framework" to see clarifying questions, '
          'or explore the side panel!';
    }

    return 'You said: *"$userText"*\n\n'
        'This is a simulated response demonstrating **ButterChat** features. '
        'In a real app, this would be connected to an AI provider. '
        'Try editing this message or clicking regenerate to see branching in action!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ButterChat Demo'),
      ),
      body: ButterChatScaffold(
        // Side panel.
        sessions: _sessions,
        activeSessionId: _activeSessionId,
        onSessionTap: _handleSessionTap,
        onNewChat: _handleNewChat,
        onDeleteSession: _handleDeleteSession,
        onRenameSession: _handleRenameSession,
        onPinSession: _handlePinSession,
        // Chat view.
        controller: _controller,
        onSendMessage: _handleSendMessage,
        onStopGeneration: _handleStopGeneration,
        onEditMessage: _handleEditMessage,
        onRegenerateResponse: _handleRegenerateResponse,
        onSubmitEdit: _handleSubmitEdit,
        onContinueGeneration: _handleContinueGeneration,
        onQuestionAnswered: _handleQuestionAnswered,
        suggestions: const [
          ButterSuggestion(
            title: 'Tell me about Flutter',
            subtitle: 'Cross-platform UI framework',
            prompt: 'Tell me about Flutter and how it works',
          ),
          ButterSuggestion(
            title: 'Help me choose',
            subtitle: 'See clarifying questions',
            prompt: 'Help me choose a framework for my project',
          ),
          ButterSuggestion(
            title: 'Say hello',
            subtitle: 'See all the features',
            prompt: 'Hello! What can you do?',
          ),
          ButterSuggestion(
            title: 'Plan my app',
            subtitle: 'Trigger planning mode',
            prompt: 'Help me plan my new Flutter app',
          ),
        ],
        messageHeaderBuilder: (context, message) {
          return Text(
            'GPT-4o',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.7),
                ),
          );
        },
        style: ButterChatStyle(
          messageStyle: ButterMessageStyle(
            avatarBuilder: (context, isUser) {
              if (isUser) return const SizedBox.shrink();
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smart_toy,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
