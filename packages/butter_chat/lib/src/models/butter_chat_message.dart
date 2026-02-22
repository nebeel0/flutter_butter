import 'butter_chat_message_status.dart';
import 'butter_chat_role.dart';
import 'butter_clarifying_question.dart';

/// An immutable chat message that forms part of a conversation tree.
///
/// Messages are linked via [parentId] and [childIds] to support branching
/// conversations (edits create new branches, regeneration creates siblings).
class ButterChatMessage {
  const ButterChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.childIds = const [],
    this.activeChildIndex = 0,
    this.status = ButterChatMessageStatus.complete,
    this.statusHistory = const [],
    this.thinkingContent = '',
    this.metadata = const {},
    this.clarifyingQuestion,
  });

  /// Unique identifier for this message.
  final String id;

  /// The role of the message sender.
  final ButterChatRole role;

  /// The message text content (partial during streaming).
  final String content;

  /// Parent message ID (null for root messages).
  final String? parentId;

  /// IDs of child messages (branches).
  final List<String> childIds;

  /// Which branch is currently displayed (index into [childIds]).
  final int activeChildIndex;

  /// Current processing status.
  final ButterChatMessageStatus status;

  /// History of status changes with timestamps.
  final List<ButterChatStatusEntry> statusHistory;

  /// Separate text for plan/thinking display (shown in collapsible section).
  final String thinkingContent;

  /// Extensible metadata (tokens, model name, latency, etc.).
  final Map<String, dynamic> metadata;

  /// An optional clarifying question attached to this message.
  final ButterClarifyingQuestion? clarifyingQuestion;

  /// When this message was created.
  final DateTime createdAt;

  /// Creates a copy with the given fields replaced.
  ButterChatMessage copyWith({
    String? id,
    ButterChatRole? role,
    String? content,
    String? parentId,
    List<String>? childIds,
    int? activeChildIndex,
    ButterChatMessageStatus? status,
    List<ButterChatStatusEntry>? statusHistory,
    String? thinkingContent,
    Map<String, dynamic>? metadata,
    ButterClarifyingQuestion? clarifyingQuestion,
    DateTime? createdAt,
  }) {
    return ButterChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      childIds: childIds ?? this.childIds,
      activeChildIndex: activeChildIndex ?? this.activeChildIndex,
      status: status ?? this.status,
      statusHistory: statusHistory ?? this.statusHistory,
      thinkingContent: thinkingContent ?? this.thinkingContent,
      metadata: metadata ?? this.metadata,
      clarifyingQuestion: clarifyingQuestion ?? this.clarifyingQuestion,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
