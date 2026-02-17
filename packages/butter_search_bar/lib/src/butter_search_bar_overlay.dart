import 'package:flutter/material.dart';

import 'butter_search_bar_controller.dart';
import 'butter_search_bar_style.dart';

/// Manages the floating suggestion overlay and scrim for [ButterSearchBar].
class ButterSearchBarOverlayManager {
  ButterSearchBarOverlayManager({
    required this.context,
    required this.controller,
    required this.layerLink,
    required this.overlayController,
    required this.scrimController,
    required this.suggestionsBuilder,
    required this.overlayStyle,
    required this.barWidth,
    this.activeDimensionBuilder,
    this.showScrim = false,
    this.scrimColor = Colors.black26,
    this.onScrimTap,
  });

  final BuildContext context;
  final ButterSearchBarController controller;
  final LayerLink layerLink;
  final AnimationController overlayController;
  final AnimationController scrimController;
  final List<Widget> Function(BuildContext, ButterSearchBarController)
      suggestionsBuilder;
  final ButterSearchBarOverlayStyle? overlayStyle;
  final double barWidth;
  final bool showScrim;
  final Color scrimColor;
  final VoidCallback? onScrimTap;

  /// Optional builder for dimension picker content. When set, the overlay
  /// renders this instead of the suggestions list.
  final Widget Function(BuildContext)? activeDimensionBuilder;

  OverlayEntry? _scrimEntry;
  OverlayEntry? _suggestionsEntry;

  bool get isShowing => _suggestionsEntry != null;

  void show() {
    if (isShowing) {
      _suggestionsEntry!.markNeedsBuild();
      return;
    }

    final overlay = Overlay.of(context);

    if (showScrim) {
      _scrimEntry = OverlayEntry(
        builder: (_) => _ScrimOverlay(
          animation: scrimController,
          color: scrimColor,
          onTap: () {
            hide();
            onScrimTap?.call();
          },
        ),
      );
      overlay.insert(_scrimEntry!);
      scrimController.forward();
    }

    _suggestionsEntry = OverlayEntry(
      builder: (_) => _SuggestionsOverlay(
        animation: overlayController,
        layerLink: layerLink,
        controller: controller,
        suggestionsBuilder: suggestionsBuilder,
        activeDimensionBuilder: activeDimensionBuilder,
        style: overlayStyle,
        barWidth: barWidth,
      ),
    );
    overlay.insert(_suggestionsEntry!);
    overlayController.forward();
    controller.showOverlay();
  }

  void hide() {
    if (!isShowing) return;
    overlayController.reverse().then((_) {
      _suggestionsEntry?.remove();
      _suggestionsEntry = null;
    });
    if (_scrimEntry != null) {
      scrimController.reverse().then((_) {
        _scrimEntry?.remove();
        _scrimEntry = null;
      });
    }
    controller.hideOverlay();
  }

  void updateSuggestions() {
    _suggestionsEntry?.markNeedsBuild();
  }

  void dispose() {
    _suggestionsEntry?.remove();
    _suggestionsEntry = null;
    _scrimEntry?.remove();
    _scrimEntry = null;
  }
}

class _ScrimOverlay extends StatelessWidget {
  const _ScrimOverlay({
    required this.animation,
    required this.color,
    required this.onTap,
  });

  final Animation<double> animation;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FadeTransition(
        opacity: animation,
        child: ColoredBox(
          color: color,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _SuggestionsOverlay extends StatelessWidget {
  const _SuggestionsOverlay({
    required this.animation,
    required this.layerLink,
    required this.controller,
    required this.suggestionsBuilder,
    required this.style,
    required this.barWidth,
    this.activeDimensionBuilder,
  });

  final Animation<double> animation;
  final LayerLink layerLink;
  final ButterSearchBarController controller;
  final List<Widget> Function(BuildContext, ButterSearchBarController)
      suggestionsBuilder;
  final Widget Function(BuildContext)? activeDimensionBuilder;
  final ButterSearchBarOverlayStyle? style;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor =
        style?.backgroundColor ?? colorScheme.surfaceContainerLow;
    final radius = style?.borderRadius ?? BorderRadius.circular(12);
    final elevation = style?.elevation ?? 4.0;
    final shadowColor =
        style?.shadowColor ?? colorScheme.shadow.withAlpha(25);
    final maxHeight = style?.maxHeight ?? 300.0;
    final offset = style?.offset ?? 4.0;
    final border = style?.border;

    // If a dimension builder is active, render that instead of suggestions.
    final Widget content;
    if (activeDimensionBuilder != null) {
      content = activeDimensionBuilder!(context);
    } else {
      final suggestions = suggestionsBuilder(context, controller);
      if (suggestions.isEmpty) return const SizedBox.shrink();
      content = ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: suggestions,
      );
    }

    return Positioned(
      width: barWidth,
      child: CompositedTransformFollower(
        link: layerLink,
        showWhenUnlinked: false,
        offset: Offset(0, offset),
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.05),
              end: Offset.zero,
            ).animate(animation),
            child: Material(
              elevation: elevation,
              shadowColor: shadowColor,
              clipBehavior: Clip.antiAlias,
              color: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: border ?? BorderSide.none,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: Padding(
                  padding: style?.padding ?? EdgeInsets.zero,
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
