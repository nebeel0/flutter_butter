/// Selection mode for clarifying question options.
enum ButterSelectionMode {
  /// Only one option can be selected at a time (radio-style).
  single,

  /// Multiple options can be selected simultaneously (checkbox-style).
  multiple,
}

/// A selectable option within a [ButterClarifyingQuestion].
class ButterQuestionOption {
  const ButterQuestionOption({
    required this.id,
    required this.label,
    this.description,
  });

  /// Unique identifier for this option.
  final String id;

  /// Display label for this option.
  final String label;

  /// Optional description providing additional context.
  final String? description;
}

/// A clarifying question that the assistant can ask the user inline,
/// with selectable options and an optional free-text "other" field.
class ButterClarifyingQuestion {
  const ButterClarifyingQuestion({
    required this.questionText,
    required this.options,
    this.selectionMode = ButterSelectionMode.single,
    this.allowOther = false,
    this.otherLabel = 'Other',
    this.otherHint = 'Type your answer...',
    this.selectedOptionIds = const [],
    this.otherText,
    this.isResolved = false,
  });

  /// The question text displayed as a heading.
  final String questionText;

  /// The available options for the user to choose from.
  final List<ButterQuestionOption> options;

  /// Whether the user can select one or multiple options.
  final ButterSelectionMode selectionMode;

  /// Whether to show a free-text "other" input.
  final bool allowOther;

  /// Label for the "other" option. Defaults to 'Other'.
  final String otherLabel;

  /// Hint text for the "other" text field. Defaults to 'Type your answer...'.
  final String otherHint;

  /// IDs of the currently selected options.
  final List<String> selectedOptionIds;

  /// Text entered in the "other" field, if any.
  final String? otherText;

  /// Whether this question has been answered and submitted.
  final bool isResolved;

  /// Creates a copy with the given fields replaced.
  ButterClarifyingQuestion copyWith({
    String? questionText,
    List<ButterQuestionOption>? options,
    ButterSelectionMode? selectionMode,
    bool? allowOther,
    String? otherLabel,
    String? otherHint,
    List<String>? selectedOptionIds,
    String? otherText,
    bool? isResolved,
  }) {
    return ButterClarifyingQuestion(
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      selectionMode: selectionMode ?? this.selectionMode,
      allowOther: allowOther ?? this.allowOther,
      otherLabel: otherLabel ?? this.otherLabel,
      otherHint: otherHint ?? this.otherHint,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      otherText: otherText ?? this.otherText,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}
