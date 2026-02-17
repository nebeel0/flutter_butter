import 'dart:ui';

import 'package:flutter/material.dart';

import 'butter_search_dimension.dart';

/// Styling configuration for a [ButterSearchBar].
///
/// All properties are optional and default to values derived from the
/// current [ThemeData] and [ColorScheme].
class ButterSearchBarStyle {
  const ButterSearchBarStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.hintColor,
    this.borderRadius,
    this.border,
    this.shape,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.overlayColor,
    this.padding,
    this.height,
    this.textStyle,
    this.hintStyle,
    this.iconSize,
    this.iconColor,
    this.cursorColor,
    this.dimensionChipStyle,
  });

  /// Background color of the search bar.
  ///
  /// Resolves against [WidgetState.focused].
  /// Defaults to `surfaceContainerHighest` (unfocused) and
  /// `surfaceContainerHigh` (focused).
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Text and icon foreground color.
  ///
  /// Defaults to `onSurface`.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// Color for the hint text.
  ///
  /// Defaults to `onSurfaceVariant`.
  final Color? hintColor;

  /// Border radius of the search bar.
  ///
  /// Defaults to `BorderRadius.circular(16)`.
  final BorderRadius? borderRadius;

  /// Border side of the search bar.
  ///
  /// Resolves against [WidgetState.focused].
  /// Defaults to none (unfocused) and a subtle 1px `outline` (focused).
  final WidgetStateProperty<BorderSide?>? border;

  /// Shape of the search bar per widget state.
  ///
  /// When set, overrides [borderRadius] and [border].
  /// Resolves against [WidgetState.focused].
  final WidgetStateProperty<OutlinedBorder?>? shape;

  /// Elevation of the search bar.
  ///
  /// Resolves against [WidgetState.focused].
  /// Defaults to `0.5` (unfocused) and `1.0` (focused).
  final WidgetStateProperty<double?>? elevation;

  /// Shadow color. Defaults to `shadow` at 10% opacity.
  final Color? shadowColor;

  /// Material 3 surface tint color.
  ///
  /// Resolves against [WidgetState.focused].
  final WidgetStateProperty<Color?>? surfaceTintColor;

  /// Ink ripple/splash overlay color.
  ///
  /// Resolves against widget states (pressed, hovered, focused).
  final WidgetStateProperty<Color?>? overlayColor;

  /// Internal padding. Defaults to `EdgeInsets.symmetric(horizontal: 16, vertical: 12)`.
  final EdgeInsetsGeometry? padding;

  /// Fixed height of the search bar. Defaults to `48.0`.
  final double? height;

  /// Text style for the input. Defaults to `bodyLarge`.
  final TextStyle? textStyle;

  /// Text style for the hint text. Derived from [textStyle] + [hintColor].
  final TextStyle? hintStyle;

  /// Size of leading/trailing icons. Defaults to `20.0`.
  final double? iconSize;

  /// Icon color. Resolves against [WidgetState.focused].
  /// Defaults to `onSurfaceVariant` (unfocused) and `primary` (focused).
  final WidgetStateProperty<Color?>? iconColor;

  /// Cursor color. Defaults to `primary`.
  final Color? cursorColor;

  /// Styling for dimension filter chips.
  final ButterSearchDimensionChipStyle? dimensionChipStyle;

  /// Creates a copy of this style with the given fields replaced.
  ButterSearchBarStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    Color? hintColor,
    BorderRadius? borderRadius,
    WidgetStateProperty<BorderSide?>? border,
    WidgetStateProperty<OutlinedBorder?>? shape,
    WidgetStateProperty<double?>? elevation,
    Color? shadowColor,
    WidgetStateProperty<Color?>? surfaceTintColor,
    WidgetStateProperty<Color?>? overlayColor,
    EdgeInsetsGeometry? padding,
    double? height,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    double? iconSize,
    WidgetStateProperty<Color?>? iconColor,
    Color? cursorColor,
    ButterSearchDimensionChipStyle? dimensionChipStyle,
  }) {
    return ButterSearchBarStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      hintColor: hintColor ?? this.hintColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      shape: shape ?? this.shape,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      overlayColor: overlayColor ?? this.overlayColor,
      padding: padding ?? this.padding,
      height: height ?? this.height,
      textStyle: textStyle ?? this.textStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      iconSize: iconSize ?? this.iconSize,
      iconColor: iconColor ?? this.iconColor,
      cursorColor: cursorColor ?? this.cursorColor,
      dimensionChipStyle: dimensionChipStyle ?? this.dimensionChipStyle,
    );
  }

  /// Linearly interpolates between two [ButterSearchBarStyle]s.
  static ButterSearchBarStyle? lerp(
    ButterSearchBarStyle? a,
    ButterSearchBarStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return ButterSearchBarStyle(
      hintColor: Color.lerp(a?.hintColor, b?.hintColor, t),
      borderRadius: BorderRadius.lerp(a?.borderRadius, b?.borderRadius, t),
      shadowColor: Color.lerp(a?.shadowColor, b?.shadowColor, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      height: lerpDouble(a?.height, b?.height, t),
      textStyle: TextStyle.lerp(a?.textStyle, b?.textStyle, t),
      hintStyle: TextStyle.lerp(a?.hintStyle, b?.hintStyle, t),
      iconSize: lerpDouble(a?.iconSize, b?.iconSize, t),
      cursorColor: Color.lerp(a?.cursorColor, b?.cursorColor, t),
    );
  }
}

/// Styling configuration for the suggestion overlay dropdown.
class ButterSearchBarOverlayStyle {
  const ButterSearchBarOverlayStyle({
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.elevation,
    this.shadowColor,
    this.maxHeight,
    this.padding,
    this.offset,
    this.dividerColor,
  });

  /// Background color of the overlay. Defaults to `surfaceContainerLow`.
  final Color? backgroundColor;

  /// Border radius. Defaults to `BorderRadius.circular(12)`.
  final BorderRadius? borderRadius;

  /// Border side of the overlay.
  final BorderSide? border;

  /// Elevation. Defaults to `4.0`.
  final double? elevation;

  /// Shadow color. Defaults to `shadow` at 10% opacity.
  final Color? shadowColor;

  /// Maximum height of the suggestions list. Defaults to `300.0`.
  final double? maxHeight;

  /// Padding inside the overlay.
  final EdgeInsetsGeometry? padding;

  /// Vertical offset from the search bar. Defaults to `4.0`.
  final double? offset;

  /// Color used for dividers between suggestion items.
  final Color? dividerColor;

  /// Creates a copy of this style with the given fields replaced.
  ButterSearchBarOverlayStyle copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    BorderSide? border,
    double? elevation,
    Color? shadowColor,
    double? maxHeight,
    EdgeInsetsGeometry? padding,
    double? offset,
    Color? dividerColor,
  }) {
    return ButterSearchBarOverlayStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      maxHeight: maxHeight ?? this.maxHeight,
      padding: padding ?? this.padding,
      offset: offset ?? this.offset,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }
}
