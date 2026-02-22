/// A suggestion prompt shown on the welcome screen or as follow-ups.
class ButterSuggestion {
  const ButterSuggestion({
    required this.title,
    this.subtitle,
    required this.prompt,
  });

  /// Display title (e.g. "Tell me about...").
  final String title;

  /// Optional secondary line shown below the title.
  final String? subtitle;

  /// The actual text sent when tapped.
  final String prompt;
}
