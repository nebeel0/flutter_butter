/// A chat session entry displayed in the side panel.
class ButterChatSession {
  const ButterChatSession({
    required this.id,
    required this.title,
    this.subtitle,
    this.createdAt,
    this.updatedAt,
    this.isPinned = false,
  });

  /// Unique identifier for this session.
  final String id;

  /// Display title for this session.
  final String title;

  /// Optional subtitle (e.g. last message preview).
  final String? subtitle;

  /// When this session was created.
  final DateTime? createdAt;

  /// When this session was last updated.
  final DateTime? updatedAt;

  /// Whether this session is pinned to the top.
  final bool isPinned;

  /// Creates a copy with the given fields replaced.
  ButterChatSession copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return ButterChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
