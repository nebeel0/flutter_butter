import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'butter_search_bar_adaptive.dart';
import 'butter_search_bar_controller.dart';
import 'butter_search_bar_overlay.dart';
import 'butter_search_bar_style.dart';
import 'butter_search_dimension.dart';

/// Direction in which an expandable search bar expands.
enum ExpandDirection { left, right, center }

/// When the clear button is shown.
enum ClearButtonBehavior { always, hasText, focused }

/// A customizable search bar with smooth animations.
///
/// Two constructors:
/// - [ButterSearchBar] — inline mode, always-visible search field.
/// - [ButterSearchBar.expandable] — starts as an icon, expands on tap.
class ButterSearchBar extends StatefulWidget {
  /// Creates an inline (always-visible) search bar.
  const ButterSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onFocusChanged,
    this.leading,
    this.trailing,
    this.suggestionsBuilder,
    this.style,
    this.overlayStyle,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    this.showClearButton = true,
    this.clearButtonBehavior = ClearButtonBehavior.hasText,
    this.showScrim = false,
    this.scrimColor = Colors.black26,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.textInputAction = TextInputAction.search,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.contextMenuBuilder,
    this.smartDashesType,
    this.smartQuotesType,
    this.constraints,
    this.dimensions,
    this.onDimensionChanged,
    this.platformMode,
    this.isFullScreen,
  })  : _expandable = false,
        collapsedIcon = null,
        collapsedSize = null,
        expandDirection = null;

  /// Creates an expandable search bar that starts as an icon button.
  const ButterSearchBar.expandable({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onFocusChanged,
    this.leading,
    this.trailing,
    this.suggestionsBuilder,
    this.style,
    this.overlayStyle,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    this.showClearButton = true,
    this.clearButtonBehavior = ClearButtonBehavior.hasText,
    this.showScrim = false,
    this.scrimColor = Colors.black26,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.textInputAction = TextInputAction.search,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.contextMenuBuilder,
    this.smartDashesType,
    this.smartQuotesType,
    this.constraints,
    this.collapsedIcon,
    this.collapsedSize,
    this.expandDirection = ExpandDirection.right,
    this.dimensions,
    this.onDimensionChanged,
    this.platformMode,
    this.isFullScreen,
  }) : _expandable = true;

  final bool _expandable;

  /// Controls text, expansion, and overlay state.
  final ButterSearchBarController? controller;

  /// An optional focus node to use for the search bar's text field.
  ///
  /// If not provided, the widget creates and manages its own [FocusNode].
  final FocusNode? focusNode;

  /// Placeholder text. Defaults to `'Search'`.
  final String hintText;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text.
  final ValueChanged<String>? onSubmitted;

  /// Called when the search bar is tapped.
  final VoidCallback? onTap;

  /// Called when a tap occurs outside the search bar's text field.
  final TapRegionCallback? onTapOutside;

  /// Called when focus changes.
  final ValueChanged<bool>? onFocusChanged;

  /// Widget shown before the text field (e.g. a search icon).
  final Widget? leading;

  /// Widgets shown after the text field (e.g. microphone, filter icons).
  ///
  /// Typically one or two action icons.
  final List<Widget>? trailing;

  /// Builds suggestion widgets below the search bar.
  final List<Widget> Function(BuildContext, ButterSearchBarController)?
      suggestionsBuilder;

  /// Visual style for the search bar.
  final ButterSearchBarStyle? style;

  /// Visual style for the overlay.
  final ButterSearchBarOverlayStyle? overlayStyle;

  /// Duration of animations. Defaults to 250ms.
  final Duration animationDuration;

  /// Curve of animations. Defaults to [Curves.easeOutCubic].
  final Curve animationCurve;

  /// Whether to show a clear button. Defaults to true.
  final bool showClearButton;

  /// When the clear button appears. Defaults to [ClearButtonBehavior.hasText].
  final ClearButtonBehavior clearButtonBehavior;

  /// Whether to show a scrim behind the overlay.
  final bool showScrim;

  /// Scrim color. Defaults to `Colors.black26`.
  final Color scrimColor;

  /// Whether to auto-focus on build.
  final bool autofocus;

  /// Whether the search bar is enabled.
  final bool enabled;

  /// Whether the text field is read-only.
  ///
  /// When true, the text cannot be modified but focus and selection
  /// still work. Defaults to false.
  final bool readOnly;

  /// Keyboard action. Defaults to [TextInputAction.search].
  final TextInputAction textInputAction;

  /// Text capitalization.
  final TextCapitalization textCapitalization;

  /// The type of keyboard to use for editing the text.
  ///
  /// If not specified, defaults to [TextInputType.text].
  final TextInputType? keyboardType;

  /// Padding around the text field when it scrolls into view.
  ///
  /// Defaults to `EdgeInsets.all(20.0)`.
  final EdgeInsets scrollPadding;

  /// Builds the text selection context menu.
  ///
  /// If not provided, uses the default platform context menu.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// Whether to use smart dashes.
  ///
  /// See [TextField.smartDashesType].
  final SmartDashesType? smartDashesType;

  /// Whether to use smart quotes.
  ///
  /// See [TextField.smartQuotesType].
  final SmartQuotesType? smartQuotesType;

  /// Optional size constraints for the bar.
  final BoxConstraints? constraints;

  /// Icon shown in collapsed state (expandable only).
  final Widget? collapsedIcon;

  /// Size of the collapsed button (expandable only). Defaults to 48.
  final double? collapsedSize;

  /// Direction to expand (expandable only). Defaults to [ExpandDirection.right].
  final ExpandDirection? expandDirection;

  /// Filter dimensions (e.g. "Where", "When", "Who").
  ///
  /// When provided, the search bar shows dimension chips instead of a text field.
  /// Also settable via [ButterSearchBarController.setDimensions].
  final List<ButterSearchDimension>? dimensions;

  /// Called when a dimension value changes.
  final void Function(String key, dynamic value)? onDimensionChanged;

  /// Platform mode override. When null, auto-detected from screen size and
  /// platform.
  final ButterPlatformMode? platformMode;

  /// Whether to use full-screen search. When null, auto-detected from
  /// [platformMode].
  final bool? isFullScreen;

  /// Whether this is an expandable search bar.
  bool get isExpandable => _expandable;

  @override
  State<ButterSearchBar> createState() => _ButterSearchBarState();
}

class _ButterSearchBarState extends State<ButterSearchBar>
    with TickerProviderStateMixin {
  late ButterSearchBarController _controller;
  bool _ownsController = false;
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  // Animation controllers
  late AnimationController _focusController;
  late AnimationController _clearButtonController;
  late AnimationController _overlayAnimController;
  late AnimationController _scrimController;
  AnimationController? _expandController;

  // Overlay
  final LayerLink _layerLink = LayerLink();
  ButterSearchBarOverlayManager? _overlayManager;

  // Platform
  ButterPlatformMode? _platformMode;

  @override
  void initState() {
    super.initState();
    _initController();
    _initFocusNode();

    _focusController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _clearButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _overlayAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scrimController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    if (widget.isExpandable) {
      _expandController = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      );
      _controller.addListener(_onControllerExpandChanged);
    }

    _controller.textEditingController.addListener(_onTextChanged);

    // Sync dimensions from widget to controller if provided.
    if (widget.dimensions != null && widget.dimensions!.isNotEmpty) {
      _controller.setDimensions(widget.dimensions!);
    }

    if (widget.autofocus && !widget.isExpandable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = ButterSearchBarController();
      _ownsController = true;
    }
  }

  void _initFocusNode() {
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _platformMode =
        widget.platformMode ?? resolvePlatformMode(context);
  }

  @override
  void didUpdateWidget(ButterSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Controller swap
    if (widget.controller != oldWidget.controller) {
      _controller.textEditingController.removeListener(_onTextChanged);
      if (widget.isExpandable) {
        _controller.removeListener(_onControllerExpandChanged);
      }
      if (_ownsController) {
        _controller.dispose();
      }
      _initController();
      _controller.textEditingController.addListener(_onTextChanged);
      if (widget.isExpandable) {
        _controller.addListener(_onControllerExpandChanged);
      }
    }

    // FocusNode swap
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      if (_ownsFocusNode) {
        _focusNode.dispose();
        _ownsFocusNode = false;
      }
      _initFocusNode();
    }

    // Dimension sync
    if (widget.dimensions != oldWidget.dimensions &&
        widget.dimensions != null) {
      _controller.setDimensions(widget.dimensions!);
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _focusController.forward();
      _updateClearButton();
      _showOverlayIfNeeded();
    } else {
      _focusController.reverse();
      _updateClearButton();
      _hideOverlay();
    }
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  void _onTextChanged() {
    _updateClearButton();
    if (_focusNode.hasFocus) {
      _showOverlayIfNeeded();
    }
  }

  void _onControllerExpandChanged() {
    if (_controller.isExpanded) {
      _expandController?.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    } else {
      _focusNode.unfocus();
      _expandController?.reverse();
      _hideOverlay();
    }
  }

  void _updateClearButton() {
    final shouldShow = widget.showClearButton && _shouldShowClear();
    if (shouldShow) {
      _clearButtonController.forward();
    } else {
      _clearButtonController.reverse();
    }
  }

  bool _shouldShowClear() {
    switch (widget.clearButtonBehavior) {
      case ClearButtonBehavior.always:
        return _controller.text.isNotEmpty;
      case ClearButtonBehavior.hasText:
        return _controller.text.isNotEmpty;
      case ClearButtonBehavior.focused:
        return _focusNode.hasFocus && _controller.text.isNotEmpty;
    }
  }

  void _showOverlayIfNeeded() {
    // When a dimension is active, show its picker in the overlay.
    if (_controller.hasDimensions &&
        _controller.activeDimensionIndex != null) {
      _showDimensionOverlay();
      return;
    }

    if (widget.suggestionsBuilder == null) return;
    final suggestions = widget.suggestionsBuilder!(context, _controller);
    if (suggestions.isEmpty) {
      _hideOverlay();
      return;
    }

    _ensureOverlayManager();
    _overlayManager!.show();
  }

  void _showDimensionOverlay() {
    final index = _controller.activeDimensionIndex!;
    final dimension = _controller.dimensions[index];

    // Dispose existing overlay manager to create fresh one with dimension builder.
    _overlayManager?.dispose();
    _overlayManager = null;

    final box = context.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 300;
    _overlayManager = ButterSearchBarOverlayManager(
      context: context,
      controller: _controller,
      layerLink: _layerLink,
      overlayController: _overlayAnimController,
      scrimController: _scrimController,
      suggestionsBuilder: widget.suggestionsBuilder ?? (_, __) => [],
      overlayStyle: widget.overlayStyle,
      barWidth: width,
      showScrim: widget.showScrim,
      scrimColor: widget.scrimColor,
      activeDimensionBuilder: (ctx) {
        return dimension.buildPicker(
          ctx,
          (newValue) {
            _controller.updateDimension(
              dimension.key,
              newValue,
              newValue?.toString(),
            );
            widget.onDimensionChanged?.call(dimension.key, newValue);
            _hideOverlay();
            _controller.advanceToNextDimension();
            // Show next dimension's overlay if there is one.
            if (_controller.activeDimensionIndex != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showOverlayIfNeeded();
              });
            }
          },
        );
      },
      onScrimTap: () {
        _controller.setActiveDimension(null);
        _focusNode.unfocus();
      },
    );
    _overlayManager!.show();
  }

  void _ensureOverlayManager() {
    if (_overlayManager != null) return;
    final box = context.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 300;
    _overlayManager = ButterSearchBarOverlayManager(
      context: context,
      controller: _controller,
      layerLink: _layerLink,
      overlayController: _overlayAnimController,
      scrimController: _scrimController,
      suggestionsBuilder: widget.suggestionsBuilder!,
      overlayStyle: widget.overlayStyle,
      barWidth: width,
      showScrim: widget.showScrim,
      scrimColor: widget.scrimColor,
      onScrimTap: () {
        _focusNode.unfocus();
      },
    );
  }

  void _hideOverlay() {
    _overlayManager?.hide();
  }

  void _onDimensionChipTapped(int index) {
    _controller.setActiveDimension(index);
    _showOverlayIfNeeded();
  }

  bool get _useFullScreen {
    if (widget.isFullScreen != null) return widget.isFullScreen!;
    return _platformMode == ButterPlatformMode.mobile;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    _controller.textEditingController.removeListener(_onTextChanged);
    if (widget.isExpandable) {
      _controller.removeListener(_onControllerExpandChanged);
    }
    _focusController.dispose();
    _clearButtonController.dispose();
    _overlayAnimController.dispose();
    _scrimController.dispose();
    _expandController?.dispose();
    _overlayManager?.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  // -- Resolve styles --

  Color _resolveBackground(ColorScheme cs, Set<WidgetState> states) {
    if (widget.style?.backgroundColor != null) {
      return widget.style!.backgroundColor!.resolve(states) ??
          cs.surfaceContainerHighest;
    }
    return states.contains(WidgetState.focused)
        ? cs.surfaceContainerHigh
        : cs.surfaceContainerHighest;
  }

  Color _resolveForeground(ColorScheme cs, Set<WidgetState> states) {
    if (widget.style?.foregroundColor != null) {
      return widget.style!.foregroundColor!.resolve(states) ?? cs.onSurface;
    }
    return cs.onSurface;
  }

  BorderSide _resolveBorder(ColorScheme cs, Set<WidgetState> states) {
    if (widget.style?.border != null) {
      return widget.style!.border!.resolve(states) ?? BorderSide.none;
    }
    return states.contains(WidgetState.focused)
        ? BorderSide(color: cs.outline.withAlpha(128), width: 1)
        : BorderSide.none;
  }

  double _resolveElevation(Set<WidgetState> states) {
    if (widget.style?.elevation != null) {
      return widget.style!.elevation!.resolve(states) ?? 0.5;
    }
    return states.contains(WidgetState.focused) ? 1.0 : 0.5;
  }

  Color _resolveIconColor(ColorScheme cs, Set<WidgetState> states) {
    if (widget.style?.iconColor != null) {
      return widget.style!.iconColor!.resolve(states) ??
          cs.onSurfaceVariant;
    }
    return states.contains(WidgetState.focused)
        ? cs.primary
        : cs.onSurfaceVariant;
  }

  ShapeBorder _resolveShape(
    ColorScheme cs,
    BorderRadius borderRadius,
    Set<WidgetState> states,
    double t,
  ) {
    // If a custom shape property is set, resolve it per state
    if (widget.style?.shape != null) {
      final unfocused = widget.style!.shape!.resolve({}) ??
          RoundedRectangleBorder(borderRadius: borderRadius);
      final focused = widget.style!.shape!.resolve({WidgetState.focused}) ??
          unfocused;
      return ShapeBorder.lerp(unfocused, focused, t)!;
    }
    // Default: use borderRadius + animated border
    final borderUnfocused = _resolveBorder(cs, {});
    final borderFocused = _resolveBorder(cs, {WidgetState.focused});
    final border = BorderSide.lerp(borderUnfocused, borderFocused, t);
    return RoundedRectangleBorder(
      borderRadius: borderRadius,
      side: border,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (widget.isExpandable) {
      result = _buildExpandable(context);
    } else {
      result = _buildInline(context);
    }

    // Wrap with keyboard shortcuts on desktop
    if (_platformMode == ButterPlatformMode.desktop &&
        _controller.hasDimensions) {
      result = CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            _controller.setActiveDimension(null);
            _hideOverlay();
            _focusNode.unfocus();
          },
          const SingleActivator(LogicalKeyboardKey.tab): () {
            _controller.advanceToNextDimension();
            _showOverlayIfNeeded();
          },
        },
        child: Focus(
          autofocus: false,
          child: result,
        ),
      );
    }

    return result;
  }

  Widget _buildInline(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: AnimatedBuilder(
        animation: _focusController,
        builder: (context, child) => _buildBar(context),
      ),
    );
  }

  Widget _buildExpandable(BuildContext context) {
    final expandAnim = CurvedAnimation(
      parent: _expandController!,
      curve: widget.animationCurve,
    );

    final collapsedSize = widget.collapsedSize ?? 48.0;
    final alignment = switch (widget.expandDirection) {
      ExpandDirection.left => Alignment.centerRight,
      ExpandDirection.center => Alignment.center,
      _ => Alignment.centerLeft,
    };

    return AnimatedBuilder(
      animation: Listenable.merge([_expandController!, _focusController]),
      builder: (context, _) {
        final isExpanded = _expandController!.value > 0;

        if (!isExpanded) {
          return _buildCollapsedIcon(collapsedSize);
        }

        return CompositedTransformTarget(
          link: _layerLink,
          child: ClipRect(
            child: Align(
              alignment: alignment,
              widthFactor: expandAnim.value.clamp(0.0, 1.0),
              child: Opacity(
                opacity: const Interval(0.3, 1.0).transform(
                  expandAnim.value.clamp(0.0, 1.0),
                ),
                child: _buildBar(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollapsedIcon(double size) {
    final cs = Theme.of(context).colorScheme;
    final iconSize = widget.style?.iconSize ?? 20.0;
    final borderRadius =
        widget.style?.borderRadius ?? BorderRadius.circular(16);

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: cs.surfaceContainerHighest,
        borderRadius: borderRadius,
        elevation: 0.5,
        shadowColor: widget.style?.shadowColor ??
            cs.shadow.withAlpha(25),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: widget.enabled ? () => _controller.expand() : null,
          child: Center(
            child: widget.collapsedIcon ??
                Icon(Icons.search, size: iconSize, color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = _focusController.value;
    final states = <WidgetState>{
      if (_focusNode.hasFocus) WidgetState.focused,
      if (!widget.enabled) WidgetState.disabled,
    };

    final bgUnfocused = _resolveBackground(cs, {});
    final bgFocused = _resolveBackground(cs, {WidgetState.focused});
    final bg = Color.lerp(bgUnfocused, bgFocused, t)!;

    final fgColor = _resolveForeground(cs, states);
    final hintColor = widget.style?.hintColor ?? cs.onSurfaceVariant;
    final cursorColor = widget.style?.cursorColor ?? cs.primary;
    final borderRadius =
        widget.style?.borderRadius ?? BorderRadius.circular(16);
    final height = widget.style?.height ?? 48.0;
    final padding = widget.style?.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final iconSize = widget.style?.iconSize ?? 20.0;
    final textStyle = widget.style?.textStyle ??
        Theme.of(context).textTheme.bodyLarge ??
        const TextStyle(fontSize: 16);
    final hintStyle =
        widget.style?.hintStyle ?? textStyle.copyWith(color: hintColor);

    final elevUnfocused = _resolveElevation({});
    final elevFocused = _resolveElevation({WidgetState.focused});
    final elevation = lerpDouble(elevUnfocused, elevFocused, t);

    final iconUnfocused = _resolveIconColor(cs, {});
    final iconFocused = _resolveIconColor(cs, {WidgetState.focused});
    final iconColor = Color.lerp(iconUnfocused, iconFocused, t)!;

    final shadowColor = widget.style?.shadowColor ??
        cs.shadow.withAlpha(25);

    final shape = _resolveShape(cs, borderRadius, states, t);

    // Resolve surfaceTintColor
    final surfaceTintColor = widget.style?.surfaceTintColor?.resolve(states);

    // Resolve overlayColor for InkWell
    final overlayColor = widget.style?.overlayColor;

    // Determine content: dimension chips or text field
    final Widget centerContent;
    if (_controller.hasDimensions) {
      centerContent = _buildDimensionChips(cs, hintColor, textStyle);
    } else {
      centerContent = Expanded(
        child: TextField(
          controller: _controller.textEditingController,
          focusNode: _focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          style: textStyle.copyWith(color: fgColor),
          cursorColor: cursorColor,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          keyboardType: widget.keyboardType,
          scrollPadding: widget.scrollPadding,
          contextMenuBuilder: widget.contextMenuBuilder,
          smartDashesType: widget.smartDashesType,
          smartQuotesType: widget.smartQuotesType,
          onTapOutside: widget.onTapOutside,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: hintStyle,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      );
    }

    return ConstrainedBox(
      constraints: widget.constraints ??
          const BoxConstraints(minWidth: 200, maxWidth: double.infinity),
      child: Material(
        color: bg,
        elevation: elevation,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: shape,
          overlayColor: overlayColor,
          onTap: widget.enabled
              ? () {
                  if (_controller.hasDimensions) {
                    // On mobile, push full-screen route
                    if (_useFullScreen) {
                      _pushFullScreenSearch();
                      return;
                    }
                    // On desktop, activate first dimension if none active
                    if (_controller.activeDimensionIndex == null) {
                      _onDimensionChipTapped(0);
                    }
                  } else {
                    _focusNode.requestFocus();
                  }
                  widget.onTap?.call();
                }
              : null,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: padding,
              child: Row(
                children: [
                  widget.leading ??
                      Icon(Icons.search, size: iconSize, color: iconColor),
                  const SizedBox(width: 12),
                  centerContent,
                  if (!_controller.hasDimensions)
                    _buildClearButton(iconSize, iconColor),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 4),
                    ...widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionChips(
    ColorScheme cs,
    Color hintColor,
    TextStyle textStyle,
  ) {
    final chipStyle = widget.style?.dimensionChipStyle;
    final dimensions = _controller.dimensions;
    final activeIndex = _controller.activeDimensionIndex;

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < dimensions.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      width: 1,
                      color: chipStyle?.dividerColor ??
                          cs.outlineVariant.withAlpha(128),
                    ),
                  ),
                ),
              _buildSingleChip(
                dimension: dimensions[i],
                index: i,
                isActive: i == activeIndex,
                cs: cs,
                hintColor: hintColor,
                textStyle: textStyle,
                chipStyle: chipStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSingleChip({
    required ButterSearchDimension dimension,
    required int index,
    required bool isActive,
    required ColorScheme cs,
    required Color hintColor,
    required TextStyle textStyle,
    ButterSearchDimensionChipStyle? chipStyle,
  }) {
    final hasValue = dimension.value != null;
    final displayText = dimension.displayValue ??
        dimension.emptyDisplayValue ??
        dimension.label;

    final bgColor = isActive
        ? (chipStyle?.activeColor ?? cs.primaryContainer)
        : (chipStyle?.inactiveColor ?? Colors.transparent);

    final labelTextStyle = chipStyle?.labelStyle ??
        textStyle.copyWith(
          fontSize: 12,
          color: hintColor,
        );

    final valueTextStyle = chipStyle?.valueStyle ??
        textStyle.copyWith(
          fontSize: 13,
          fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
          color: hasValue ? cs.onSurface : hintColor,
        );

    final radius =
        chipStyle?.borderRadius ?? BorderRadius.circular(8);
    final chipPadding = chipStyle?.padding ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 2);

    return GestureDetector(
      onTap: () => _onDimensionChipTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: radius,
        ),
        padding: chipPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dimension.label, style: labelTextStyle),
            const SizedBox(width: 4),
            Text(displayText, style: valueTextStyle),
          ],
        ),
      ),
    );
  }

  void _pushFullScreenSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ButterSearchBarFullScreenRoute(
          child: _FullScreenDimensionContent(
            controller: _controller,
            dimensions: _controller.dimensions,
            onDimensionChanged: widget.onDimensionChanged,
            overlayStyle: widget.overlayStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton(double iconSize, Color iconColor) {
    if (!widget.showClearButton) return const SizedBox.shrink();

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _clearButtonController,
        curve: Curves.easeOut,
      ),
      child: FadeTransition(
        opacity: _clearButtonController,
        child: SizedBox(
          width: iconSize + 8,
          height: iconSize + 8,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: iconSize,
            icon: Icon(Icons.close, color: iconColor),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call('');
              _focusNode.requestFocus();
            },
          ),
        ),
      ),
    );
  }
}

/// Content shown inside the full-screen route for dimension-based search.
class _FullScreenDimensionContent extends StatefulWidget {
  const _FullScreenDimensionContent({
    required this.controller,
    required this.dimensions,
    this.onDimensionChanged,
    this.overlayStyle,
  });

  final ButterSearchBarController controller;
  final List<ButterSearchDimension> dimensions;
  final void Function(String key, dynamic value)? onDimensionChanged;
  final ButterSearchBarOverlayStyle? overlayStyle;

  @override
  State<_FullScreenDimensionContent> createState() =>
      _FullScreenDimensionContentState();
}

class _FullScreenDimensionContentState
    extends State<_FullScreenDimensionContent> {
  int _activeDimension = 0;

  @override
  Widget build(BuildContext context) {
    final dimension = widget.dimensions[_activeDimension];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dimension tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < widget.dimensions.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(widget.dimensions[i].label),
                    selected: i == _activeDimension,
                    onSelected: (_) => setState(() => _activeDimension = i),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Active dimension picker
        Expanded(
          child: dimension.buildPicker(
            context,
            (newValue) {
              widget.controller.updateDimension(
                dimension.key,
                newValue,
                newValue?.toString(),
              );
              widget.onDimensionChanged?.call(dimension.key, newValue);

              // Auto-advance to next dimension
              setState(() {
                if (_activeDimension < widget.dimensions.length - 1) {
                  _activeDimension++;
                }
              });
            },
          ),
        ),
      ],
    );
  }
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;
