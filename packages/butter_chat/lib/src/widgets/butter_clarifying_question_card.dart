import 'package:flutter/material.dart';

import '../butter_chat_style.dart';
import '../models/butter_clarifying_question.dart';

/// Renders a clarifying question card with selectable options.
///
/// When unresolved, displays interactive option tiles and a submit button.
/// When resolved, displays a read-only summary of the selected answers.
class ButterClarifyingQuestionCard extends StatefulWidget {
  const ButterClarifyingQuestionCard({
    super.key,
    required this.question,
    required this.onSubmit,
    this.style,
  });

  final ButterClarifyingQuestion question;

  /// Called when the user submits their answer.
  /// Receives (selectedOptionIds, otherText).
  final void Function(List<String> selectedOptionIds, String? otherText)
      onSubmit;

  final ButterClarifyingQuestionStyle? style;

  @override
  State<ButterClarifyingQuestionCard> createState() =>
      _ButterClarifyingQuestionCardState();
}

class _ButterClarifyingQuestionCardState
    extends State<ButterClarifyingQuestionCard> {
  late Set<String> _selectedIds;
  late TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.question.selectedOptionIds};
    _otherController =
        TextEditingController(text: widget.question.otherText ?? '');
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _toggleOption(String id) {
    setState(() {
      if (widget.question.selectionMode == ButterSelectionMode.single) {
        _selectedIds = {id};
      } else {
        if (_selectedIds.contains(id)) {
          _selectedIds.remove(id);
        } else {
          _selectedIds.add(id);
        }
      }
    });
  }

  void _submit() {
    final otherText = _otherController.text.trim();
    widget.onSubmit(
      _selectedIds.toList(),
      otherText.isNotEmpty ? otherText : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.question.isResolved) {
      return _buildResolved(context);
    }
    return _buildUnresolved(context);
  }

  Widget _buildUnresolved(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = widget.style;

    final bgColor = style?.backgroundColor ?? colorScheme.surfaceContainerLow;
    final borderRadius =
        style?.borderRadius ?? BorderRadius.circular(12);
    final border = style?.border ??
        BorderSide(color: colorScheme.outlineVariant, width: 1);
    final padding =
        style?.padding ?? const EdgeInsets.all(16);
    final questionTextStyle = style?.questionTextStyle ??
        theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);
    final optionBorderRadius =
        style?.optionBorderRadius ?? BorderRadius.circular(8);
    final optionPadding =
        style?.optionPadding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

    final isSingle =
        widget.question.selectionMode == ButterSelectionMode.single;
    final canSubmit = _selectedIds.isNotEmpty ||
        _otherController.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        border: Border.fromBorderSide(border),
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.question.questionText, style: questionTextStyle),
          const SizedBox(height: 12),
          ...widget.question.options.map((option) {
            final isSelected = _selectedIds.contains(option.id);
            final selectedColor = style?.selectedOptionColor ??
                colorScheme.primaryContainer;
            final unselectedColor = style?.unselectedOptionColor ??
                colorScheme.surfaceContainerHighest;
            final optionLabelStyle = style?.optionLabelStyle ??
                theme.textTheme.bodyMedium;
            final optionDescriptionStyle = style?.optionDescriptionStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                );

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isSelected ? selectedColor : unselectedColor,
                borderRadius: optionBorderRadius,
                child: InkWell(
                  onTap: () => _toggleOption(option.id),
                  borderRadius: optionBorderRadius,
                  child: Padding(
                    padding: optionPadding,
                    child: Row(
                      children: [
                        if (isSingle)
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          )
                        else
                          Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 20,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(option.label, style: optionLabelStyle),
                              if (option.description != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    option.description!,
                                    style: optionDescriptionStyle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (widget.question.allowOther) ...[
            const SizedBox(height: 4),
            TextField(
              controller: _otherController,
              decoration: InputDecoration(
                labelText: widget.question.otherLabel,
                hintText: widget.question.otherHint,
                border: OutlineInputBorder(
                  borderRadius: optionBorderRadius,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: canSubmit ? _submit : null,
              style: style?.submitButtonStyle,
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolved(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = widget.style;

    final bgColor =
        style?.resolvedBackgroundColor ?? colorScheme.surfaceContainerLowest;
    final borderRadius =
        style?.borderRadius ?? BorderRadius.circular(12);
    final padding =
        style?.padding ?? const EdgeInsets.all(16);
    final questionTextStyle = style?.questionTextStyle ??
        theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);

    // Build answer labels.
    final optionMap = {
      for (final opt in widget.question.options) opt.id: opt.label,
    };
    final selectedLabels = widget.question.selectedOptionIds
        .where(optionMap.containsKey)
        .map((id) => optionMap[id]!)
        .toList();
    if (widget.question.otherText != null &&
        widget.question.otherText!.isNotEmpty) {
      selectedLabels.add(widget.question.otherText!);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child:
                    Text(widget.question.questionText, style: questionTextStyle),
              ),
            ],
          ),
          if (selectedLabels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selectedLabels.map((label) {
                return Chip(
                  label: Text(label),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
