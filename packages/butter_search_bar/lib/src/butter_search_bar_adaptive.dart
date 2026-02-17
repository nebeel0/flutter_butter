import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Platform mode that determines overlay behavior and touch targets.
enum ButterPlatformMode {
  /// Full-screen search route, larger touch targets, back arrow navigation.
  mobile,

  /// Floating dropdown overlay, keyboard shortcuts, compact targets.
  desktop,
}

/// Resolves the platform mode based on screen width and platform.
///
/// Uses `width < 600` as the primary signal. Falls back to
/// [defaultTargetPlatform] for native platforms (iOS/Android → mobile).
ButterPlatformMode resolvePlatformMode(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return ButterPlatformMode.mobile;

  // On native mobile platforms, still prefer mobile mode even if wide
  // (e.g. tablet in landscape is handled by the width check above).
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.android:
      return ButterPlatformMode.mobile;
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return ButterPlatformMode.desktop;
  }
}

/// A full-screen search route used on mobile platforms.
///
/// Renders the search bar content with suggestions/dimensions in a
/// full-screen view with a back button and 300ms transitions.
class ButterSearchBarFullScreenRoute extends StatelessWidget {
  const ButterSearchBarFullScreenRoute({
    super.key,
    required this.child,
  });

  /// The search content to display full-screen.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Search'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
