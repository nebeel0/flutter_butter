/// The current status of a chat message.
enum ButterChatMessageStatus {
  /// Message created but not yet processing.
  pending,

  /// Assistant is generating content (tokens arriving).
  streaming,

  /// Assistant is in thinking/planning mode.
  thinking,

  /// Message generation is complete.
  complete,

  /// Generation was stopped by the user.
  stopped,

  /// An error occurred during generation.
  error,
}

/// A timestamped entry in a message's status history.
class ButterChatStatusEntry {
  const ButterChatStatusEntry({
    required this.status,
    required this.timestamp,
    this.label,
  });

  /// The status at this point in time.
  final ButterChatMessageStatus status;

  /// When this status was set.
  final DateTime timestamp;

  /// Optional human-readable label (e.g. "Searching...", "Analyzing...").
  final String? label;
}
