import 'package:flutter/widgets.dart';

/// Layout mode for filter dimensions.
enum DimensionLayout {
  /// Chips displayed horizontally inside the search bar.
  inline,

  /// Taller multi-section panel with stacked dimensions.
  expanded,
}

/// Data model for a single filter dimension (e.g. "Where", "When", "Who").
///
/// Each dimension has a unique [key], a display [label], an optional [icon],
/// and a [builder] that renders the picker UI when the dimension is active.
class ButterSearchDimension<T> {
  const ButterSearchDimension({
    required this.key,
    required this.label,
    required this.builder,
    this.icon,
    this.value,
    this.displayValue,
    this.emptyDisplayValue,
  });

  /// Unique identifier for this dimension (e.g. 'where', 'when', 'who').
  final String key;

  /// Display label shown on the chip (e.g. "Where").
  final String label;

  /// Optional icon shown alongside the label.
  final IconData? icon;

  /// The currently selected value.
  final T? value;

  /// Human-readable display of the current value (e.g. "Paris", "Mar 15-20").
  final String? displayValue;

  /// Placeholder shown when no value is selected (e.g. "Anywhere", "Any week").
  final String? emptyDisplayValue;

  /// Builds the picker UI for this dimension.
  ///
  /// Receives the current value and a callback to commit a new value.
  final Widget Function(
    BuildContext context,
    T? currentValue,
    ValueChanged<T?> onChanged,
  ) builder;

  /// Creates a copy with the given fields replaced.
  ButterSearchDimension<T> copyWith({
    T? value,
    String? displayValue,
  }) {
    return ButterSearchDimension<T>(
      key: key,
      label: label,
      icon: icon,
      builder: builder,
      value: value ?? this.value,
      displayValue: displayValue ?? this.displayValue,
      emptyDisplayValue: emptyDisplayValue,
    );
  }

  /// Invokes [builder] with the current [value] and a dynamic-compatible
  /// callback that wraps [onChanged].
  ///
  /// This bridges the generic type gap when calling the builder through
  /// an untyped `ButterSearchDimension` reference.
  Widget buildPicker(
    BuildContext context,
    void Function(dynamic value) onChanged,
  ) {
    return builder(context, value, (T? newValue) => onChanged(newValue));
  }

  /// Returns a copy with value and displayValue reset to null.
  ButterSearchDimension<T> clearValue() {
    return ButterSearchDimension<T>(
      key: key,
      label: label,
      icon: icon,
      builder: builder,
      emptyDisplayValue: emptyDisplayValue,
    );
  }
}

/// Styling for dimension chips displayed in the search bar.
class ButterSearchDimensionChipStyle {
  const ButterSearchDimensionChipStyle({
    this.activeColor,
    this.inactiveColor,
    this.labelStyle,
    this.valueStyle,
    this.dividerColor,
    this.borderRadius,
    this.padding,
  });

  /// Background color of the active (selected) chip.
  final Color? activeColor;

  /// Background color of inactive chips.
  final Color? inactiveColor;

  /// Text style for the dimension label.
  final TextStyle? labelStyle;

  /// Text style for the dimension value.
  final TextStyle? valueStyle;

  /// Color of dividers between chips.
  final Color? dividerColor;

  /// Border radius of chips.
  final BorderRadius? borderRadius;

  /// Padding inside each chip.
  final EdgeInsetsGeometry? padding;
}
