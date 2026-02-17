import 'package:flutter/widgets.dart';

import 'butter_search_dimension.dart';

/// Controls a [ButterSearchBar]'s text, expansion state, overlay visibility,
/// and filter dimension state.
class ButterSearchBarController extends ChangeNotifier {
  ButterSearchBarController({String? text})
      : _textEditingController = TextEditingController(text: text) {
    _textEditingController.addListener(notifyListeners);
  }

  final TextEditingController _textEditingController;

  /// The underlying [TextEditingController].
  TextEditingController get textEditingController => _textEditingController;

  /// The current text value.
  String get text => _textEditingController.text;
  set text(String value) {
    _textEditingController.text = value;
  }

  // -- Expansion state --

  bool _isExpanded = false;

  /// Whether the search bar is currently expanded (expandable mode).
  bool get isExpanded => _isExpanded;

  /// Expands the search bar.
  void expand() {
    if (!_isExpanded) {
      _isExpanded = true;
      notifyListeners();
    }
  }

  /// Collapses the search bar.
  void collapse() {
    if (_isExpanded) {
      _isExpanded = false;
      notifyListeners();
    }
  }

  /// Toggles the expansion state.
  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  // -- Overlay state --

  bool _isOverlayVisible = false;

  /// Whether the suggestion overlay is currently visible.
  bool get isOverlayVisible => _isOverlayVisible;

  /// Shows the suggestion overlay.
  void showOverlay() {
    if (!_isOverlayVisible) {
      _isOverlayVisible = true;
      notifyListeners();
    }
  }

  /// Hides the suggestion overlay.
  void hideOverlay() {
    if (_isOverlayVisible) {
      _isOverlayVisible = false;
      notifyListeners();
    }
  }

  /// Clears the text and hides the overlay.
  void clear() {
    _textEditingController.clear();
    hideOverlay();
  }

  // -- Dimension state --

  List<ButterSearchDimension> _dimensions = [];
  int? _activeDimensionIndex;

  /// The current list of filter dimensions.
  List<ButterSearchDimension> get dimensions =>
      List.unmodifiable(_dimensions);

  /// Whether any dimensions have been configured.
  bool get hasDimensions => _dimensions.isNotEmpty;

  /// The index of the currently active (being edited) dimension, or null.
  int? get activeDimensionIndex => _activeDimensionIndex;

  /// Whether all dimensions have a non-null value.
  bool get allDimensionsFilled =>
      _dimensions.isNotEmpty &&
      _dimensions.every((d) => d.value != null);

  /// A summary string joining all dimension display values with " · ".
  ///
  /// Uses [ButterSearchDimension.displayValue] if set, otherwise
  /// [ButterSearchDimension.emptyDisplayValue], falling back to the label.
  String get dimensionSummary {
    return _dimensions.map((d) {
      return d.displayValue ?? d.emptyDisplayValue ?? d.label;
    }).join(' · ');
  }

  /// Replaces the current dimensions list.
  void setDimensions(List<ButterSearchDimension> dimensions) {
    _dimensions = List.of(dimensions);
    _activeDimensionIndex = null;
    notifyListeners();
  }

  /// Updates a single dimension by [key] with a new [value] and [displayValue].
  void updateDimension(String key, dynamic value, String? displayValue) {
    final index = _dimensions.indexWhere((d) => d.key == key);
    if (index == -1) return;
    _dimensions[index] = _dimensions[index].copyWith(
      value: value,
      displayValue: displayValue,
    );
    notifyListeners();
  }

  /// Sets the active dimension index (which picker is open).
  void setActiveDimension(int? index) {
    if (_activeDimensionIndex != index) {
      _activeDimensionIndex = index;
      notifyListeners();
    }
  }

  /// Advances to the next unfilled dimension, or clears the active index
  /// if all are filled.
  void advanceToNextDimension() {
    if (_dimensions.isEmpty) return;

    final current = _activeDimensionIndex ?? -1;
    // Try to find the next unfilled dimension after the current one
    for (var i = current + 1; i < _dimensions.length; i++) {
      if (_dimensions[i].value == null) {
        _activeDimensionIndex = i;
        notifyListeners();
        return;
      }
    }
    // No more unfilled dimensions — deactivate
    _activeDimensionIndex = null;
    notifyListeners();
  }

  /// Resets all dimension values to null.
  void clearDimensions() {
    for (var i = 0; i < _dimensions.length; i++) {
      _dimensions[i] = _dimensions[i].clearValue();
    }
    _activeDimensionIndex = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
