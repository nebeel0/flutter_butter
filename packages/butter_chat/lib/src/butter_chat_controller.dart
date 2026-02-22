import 'package:flutter/foundation.dart';

import 'models/butter_chat_message.dart';
import 'models/butter_chat_message_status.dart';
import 'models/butter_chat_role.dart';
import 'models/butter_clarifying_question.dart';

/// Manages chat conversation state including a message tree for branching.
///
/// The controller does NOT make network calls. The consumer drives streaming
/// by calling [appendContent], [appendThinkingContent], and
/// [setMessageStatus] in response to LLM events.
///
/// Messages form a tree via parentId/childIds. [activeMessages] computes the
/// linear path through the tree that should be displayed.
class ButterChatController extends ChangeNotifier {
  ButterChatController({List<ButterChatMessage>? initialMessages}) {
    if (initialMessages != null) {
      for (final msg in initialMessages) {
        _messages[msg.id] = msg;
      }
    }
  }

  /// Flat map of all messages by ID for O(1) lookups.
  final Map<String, ButterChatMessage> _messages = {};

  /// Optional status label shown in the status bar (e.g. "Searching...").
  String? _statusLabel;

  /// Current status label text, or null if not showing.
  String? get statusLabel => _statusLabel;

  /// All messages by ID (unmodifiable view).
  Map<String, ButterChatMessage> get messages =>
      Map.unmodifiable(_messages);

  /// Whether any message is currently streaming.
  bool get isStreaming => _messages.values.any(
        (m) =>
            m.status == ButterChatMessageStatus.streaming ||
            m.status == ButterChatMessageStatus.thinking,
      );

  /// The currently streaming message, if any.
  ButterChatMessage? get streamingMessage {
    try {
      return _messages.values.firstWhere(
        (m) =>
            m.status == ButterChatMessageStatus.streaming ||
            m.status == ButterChatMessageStatus.thinking,
      );
    } on StateError {
      return null;
    }
  }

  /// Computes the linear path of messages through the tree following active
  /// branches. This is what should be displayed in the message list.
  List<ButterChatMessage> get activeMessages {
    // Find root messages (no parent).
    final roots = _messages.values
        .where((m) => m.parentId == null)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (roots.isEmpty) return [];

    final result = <ButterChatMessage>[];
    // Walk the tree from the first root, following active branches.
    ButterChatMessage? current = roots.first;
    while (current != null) {
      result.add(current);
      if (current.childIds.isEmpty) break;
      final activeIndex =
          current.activeChildIndex.clamp(0, current.childIds.length - 1);
      current = _messages[current.childIds[activeIndex]];
    }
    return result;
  }

  /// Adds a user message, linking it as a child of [parentId] if provided.
  /// If [parentId] is null and messages exist, links to the last active message.
  /// Returns the message ID.
  String addUserMessage({
    required String id,
    required String content,
    String? parentId,
    Map<String, dynamic> metadata = const {},
  }) {
    final effectiveParentId = parentId ?? _lastActiveMessageId;

    final message = ButterChatMessage(
      id: id,
      role: ButterChatRole.user,
      content: content,
      parentId: effectiveParentId,
      status: ButterChatMessageStatus.complete,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _messages[id] = message;
    _linkChild(effectiveParentId, id);
    notifyListeners();
    return id;
  }

  /// Adds an assistant message placeholder for streaming.
  /// Returns the message ID.
  String addAssistantMessage({
    required String id,
    String? parentId,
    Map<String, dynamic> metadata = const {},
  }) {
    final effectiveParentId = parentId ?? _lastActiveMessageId;

    final message = ButterChatMessage(
      id: id,
      role: ButterChatRole.assistant,
      content: '',
      parentId: effectiveParentId,
      status: ButterChatMessageStatus.pending,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _messages[id] = message;
    _linkChild(effectiveParentId, id);
    notifyListeners();
    return id;
  }

  /// Appends a token to the message content (hot path during streaming).
  void appendContent(String id, String token) {
    final msg = _messages[id];
    if (msg == null) return;
    _messages[id] = msg.copyWith(content: msg.content + token);
    notifyListeners();
  }

  /// Appends a token to the thinking/plan content.
  void appendThinkingContent(String id, String token) {
    final msg = _messages[id];
    if (msg == null) return;
    _messages[id] =
        msg.copyWith(thinkingContent: msg.thinkingContent + token);
    notifyListeners();
  }

  /// Updates the status of a message and records it in the status history.
  void setMessageStatus(
    String id,
    ButterChatMessageStatus status, {
    String? label,
  }) {
    final msg = _messages[id];
    if (msg == null) return;

    final entry = ButterChatStatusEntry(
      status: status,
      timestamp: DateTime.now(),
      label: label,
    );

    _messages[id] = msg.copyWith(
      status: status,
      statusHistory: [...msg.statusHistory, entry],
    );
    notifyListeners();
  }

  /// Sets the status bar label text (e.g. "Searching...", "Analyzing...").
  /// Pass null to clear.
  void setStatusLabel(String? label) {
    if (_statusLabel == label) return;
    _statusLabel = label;
    notifyListeners();
  }

  /// Stops the currently streaming message by setting its status to stopped.
  void stopStreaming() {
    final msg = streamingMessage;
    if (msg == null) return;
    setMessageStatus(msg.id, ButterChatMessageStatus.stopped);
    _statusLabel = null;
  }

  /// Creates a new branch by editing a user message.
  ///
  /// The original message is kept. A new user message with [newContent] is
  /// created as a sibling (same parent), and the parent's active child is
  /// switched to the new message. Returns the new message ID.
  String editUserMessage(String id, String newContent, {required String newId}) {
    final original = _messages[id];
    if (original == null || original.role != ButterChatRole.user) return id;

    final parentId = original.parentId;

    final newMessage = ButterChatMessage(
      id: newId,
      role: ButterChatRole.user,
      content: newContent,
      parentId: parentId,
      status: ButterChatMessageStatus.complete,
      createdAt: DateTime.now(),
    );

    _messages[newId] = newMessage;
    _linkChild(parentId, newId);

    // Switch parent's active child to the new message.
    if (parentId != null) {
      final parent = _messages[parentId]!;
      final newIndex = parent.childIds.indexOf(newId);
      if (newIndex >= 0) {
        _messages[parentId] = parent.copyWith(activeChildIndex: newIndex);
      }
    }

    notifyListeners();
    return newId;
  }

  /// Creates a sibling branch for regenerating an assistant response.
  ///
  /// Returns the new message ID. The parent's active child is switched to
  /// the new message. The consumer should then stream content into it.
  String regenerateResponse(String id, {required String newId}) {
    final original = _messages[id];
    if (original == null || original.role != ButterChatRole.assistant) return id;

    final parentId = original.parentId;

    final newMessage = ButterChatMessage(
      id: newId,
      role: ButterChatRole.assistant,
      content: '',
      parentId: parentId,
      status: ButterChatMessageStatus.pending,
      createdAt: DateTime.now(),
    );

    _messages[newId] = newMessage;
    _linkChild(parentId, newId);

    // Switch parent's active child to the new message.
    if (parentId != null) {
      final parent = _messages[parentId]!;
      final newIndex = parent.childIds.indexOf(newId);
      if (newIndex >= 0) {
        _messages[parentId] = parent.copyWith(activeChildIndex: newIndex);
      }
    }

    notifyListeners();
    return newId;
  }

  /// Switches to a different branch at the given message.
  void switchBranch(String id, int index) {
    final msg = _messages[id];
    if (msg == null) return;
    if (index < 0 || index >= msg.childIds.length) return;
    if (msg.activeChildIndex == index) return;
    _messages[id] = msg.copyWith(activeChildIndex: index);
    notifyListeners();
  }

  /// Creates an assistant message with a clarifying question attached.
  ///
  /// The message is marked as complete since it is fully formed. If [parentId]
  /// is null and messages exist, links to the last active message.
  String addClarifyingQuestion({
    required String id,
    required ButterClarifyingQuestion question,
    String? parentId,
    String content = '',
    Map<String, dynamic> metadata = const {},
  }) {
    final effectiveParentId = parentId ?? _lastActiveMessageId;

    final message = ButterChatMessage(
      id: id,
      role: ButterChatRole.assistant,
      content: content,
      parentId: effectiveParentId,
      status: ButterChatMessageStatus.complete,
      createdAt: DateTime.now(),
      metadata: metadata,
      clarifyingQuestion: question,
    );

    _messages[id] = message;
    _linkChild(effectiveParentId, id);
    notifyListeners();
    return id;
  }

  /// Resolves a clarifying question by recording the selected answers.
  ///
  /// Marks the question as resolved with the given [selectedOptionIds] and
  /// optional [otherText].
  void resolveClarifyingQuestion(
    String messageId, {
    required List<String> selectedOptionIds,
    String? otherText,
  }) {
    final msg = _messages[messageId];
    if (msg == null || msg.clarifyingQuestion == null) return;

    _messages[messageId] = msg.copyWith(
      clarifyingQuestion: msg.clarifyingQuestion!.copyWith(
        selectedOptionIds: selectedOptionIds,
        otherText: otherText,
        isResolved: true,
      ),
    );
    notifyListeners();
  }

  /// Links a child message to its parent.
  void _linkChild(String? parentId, String childId) {
    if (parentId == null) return;
    final parent = _messages[parentId];
    if (parent == null) return;
    if (parent.childIds.contains(childId)) return;
    _messages[parentId] = parent.copyWith(
      childIds: [...parent.childIds, childId],
      activeChildIndex: parent.childIds.length, // Point to newly added child.
    );
  }

  /// Returns the ID of the last message on the active path, or null.
  String? get _lastActiveMessageId {
    final active = activeMessages;
    return active.isEmpty ? null : active.last.id;
  }
}
