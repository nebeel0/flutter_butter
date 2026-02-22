import 'dart:async';

import 'package:flutter/material.dart';

/// Stackable in-app toast notification system with slide-in animation.
///
/// Call [SmoothToast.setOverlay] with your app's overlay before showing toasts.
/// Typically done via [SmoothToast.setNavigatorKey] with your [MaterialApp]'s
/// navigator key.
///
/// ```dart
/// final navigatorKey = GlobalKey<NavigatorState>();
///
/// MaterialApp(navigatorKey: navigatorKey, ...);
///
/// SmoothToast.setNavigatorKey(navigatorKey);
/// SmoothToast.success('Item saved!');
/// ```
class SmoothToast {
  SmoothToast._();

  static GlobalKey<NavigatorState>? _navigatorKey;
  static OverlayState? _overlay;

  static final List<_ToastEntry> _activeToasts = [];
  static int _nextId = 0;

  /// Maximum number of toasts visible at once. Oldest is dismissed when exceeded.
  static int maxStack = 3;

  /// How long each toast stays visible before auto-dismissing.
  static Duration autoDismissDuration = const Duration(seconds: 4);

  static const double _toastHeight = 72;
  static const double _toastGap = 8;

  /// Resets all state. Use in test tearDown to prevent leaks between tests.
  @visibleForTesting
  static void reset() {
    dismissAll();
    _navigatorKey = null;
    _overlay = null;
    maxStack = 3;
    autoDismissDuration = const Duration(seconds: 4);
  }

  /// Set the navigator key so toasts can find the overlay.
  /// Call this once after creating your [MaterialApp].
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    _overlay = null;
  }

  /// Directly set the overlay state. Alternative to [setNavigatorKey].
  static void setOverlay(OverlayState overlay) {
    _overlay = overlay;
  }

  /// Show a success toast (green).
  static void success(
    String message, {
    String? title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      title: title ?? 'Success',
      message: message,
      color: Colors.green,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show an error toast (red).
  static void error(
    String message, {
    String? title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      title: title ?? 'Error',
      message: message,
      color: Colors.red,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show an info toast (blue).
  static void info(
    String message, {
    String? title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      title: title ?? 'Info',
      message: message,
      color: Colors.blue,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show a toast with full customization.
  static void show({
    required String title,
    required String message,
    required Color color,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = _overlay ?? _navigatorKey?.currentState?.overlay;
    if (overlay == null) {
      debugPrint(
        'SmoothToast: No overlay found. '
        'Call SmoothToast.setNavigatorKey() or SmoothToast.setOverlay() first.',
      );
      return;
    }

    // Dismiss oldest if at max stack
    if (_activeToasts.length >= maxStack) {
      _dismiss(_activeToasts.first);
    }

    late _ToastEntry entry;
    final overlayEntry = OverlayEntry(
      builder: (context) {
        final index = _activeToasts.indexOf(entry);
        final topOffset = MediaQuery.of(context).padding.top +
            16 +
            (index >= 0 ? index * (_toastHeight + _toastGap) : 0);

        return _AnimatedToast(
          key: ValueKey(entry.id),
          topOffset: topOffset,
          title: title,
          message: message,
          color: color,
          subtitle: subtitle,
          actionLabel: actionLabel,
          onAction: onAction != null
              ? () {
                  _dismiss(entry);
                  onAction();
                }
              : null,
          onDismiss: () => _dismiss(entry),
        );
      },
    );

    entry = _ToastEntry(
      id: _nextId++,
      overlayEntry: overlayEntry,
    );

    _activeToasts.add(entry);
    overlay.insert(overlayEntry);

    entry.timer = Timer(autoDismissDuration, () {
      _dismiss(entry);
    });
  }

  /// Dismiss all active toasts.
  static void dismissAll() {
    for (final entry in List.of(_activeToasts)) {
      _dismiss(entry);
    }
  }

  static void _dismiss(_ToastEntry entry) {
    entry.timer?.cancel();
    entry.timer = null;
    if (!entry.dismissed) {
      entry.dismissed = true;
      entry.overlayEntry.remove();
      _activeToasts.remove(entry);

      // Rebuild remaining toasts to update positions
      for (final remaining in _activeToasts) {
        remaining.overlayEntry.markNeedsBuild();
      }
    }
  }
}

class _ToastEntry {
  final int id;
  final OverlayEntry overlayEntry;
  Timer? timer;
  bool dismissed = false;

  _ToastEntry({required this.id, required this.overlayEntry});
}

class _AnimatedToast extends StatefulWidget {
  final double topOffset;
  final String title;
  final String message;
  final Color color;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _AnimatedToast({
    super.key,
    required this.topOffset,
    required this.title,
    required this.message,
    required this.color,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      top: widget.topOffset,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: widget.color,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.message,
                            style: const TextStyle(color: Colors.white),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.actionLabel != null &&
                        widget.onAction != null) ...[
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: widget.onAction,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          side: const BorderSide(
                            color: Colors.white54,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          widget.actionLabel!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
