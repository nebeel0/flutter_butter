import 'package:flutter/material.dart';

/// Visual styling for the [RoadMap] widget.
///
/// All fields are optional. When null, defaults are derived from
/// [Theme.of(context).colorScheme].
@immutable
class RoadMapStyle {
  /// Creates a road map style.
  const RoadMapStyle({
    this.blockedColor,
    this.readyColor,
    this.completeColor,
    this.nodeTitleStyle,
    this.nodeContentStyle,
    this.sidebarItemStyle,
    this.pagePadding,
    this.sidebarWidth,
  });

  /// Color for blocked nodes. Defaults to [ColorScheme.outline].
  final Color? blockedColor;

  /// Color for ready nodes. Defaults to [ColorScheme.primary].
  final Color? readyColor;

  /// Color for complete nodes. Defaults to [ColorScheme.tertiary].
  final Color? completeColor;

  /// Text style for node titles on the page view.
  final TextStyle? nodeTitleStyle;

  /// Text style for node content on the page view.
  final TextStyle? nodeContentStyle;

  /// Text style for sidebar items.
  final TextStyle? sidebarItemStyle;

  /// Padding around the node page content.
  final EdgeInsets? pagePadding;

  /// Width of the persistent sidebar on desktop. Defaults to 260.
  final double? sidebarWidth;

  /// Returns a copy with the given fields replaced.
  RoadMapStyle copyWith({
    Color? blockedColor,
    Color? readyColor,
    Color? completeColor,
    TextStyle? nodeTitleStyle,
    TextStyle? nodeContentStyle,
    TextStyle? sidebarItemStyle,
    EdgeInsets? pagePadding,
    double? sidebarWidth,
  }) {
    return RoadMapStyle(
      blockedColor: blockedColor ?? this.blockedColor,
      readyColor: readyColor ?? this.readyColor,
      completeColor: completeColor ?? this.completeColor,
      nodeTitleStyle: nodeTitleStyle ?? this.nodeTitleStyle,
      nodeContentStyle: nodeContentStyle ?? this.nodeContentStyle,
      sidebarItemStyle: sidebarItemStyle ?? this.sidebarItemStyle,
      pagePadding: pagePadding ?? this.pagePadding,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
    );
  }
}
