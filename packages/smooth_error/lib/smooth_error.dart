import 'package:flutter/material.dart';

/// A full-page error screen with icon, title, subtitle, and optional retry button.
///
/// Use for route-level errors like network failures or unexpected crashes.
class SmoothErrorScreen extends StatelessWidget {
  /// The main error title.
  final String title;

  /// A longer explanation of the error.
  final String subtitle;

  /// The icon displayed above the title.
  final IconData icon;

  /// Called when the retry button is tapped. If null, no button is shown.
  final VoidCallback? onRetry;

  /// Label for the retry button.
  final String retryLabel;

  const SmoothErrorScreen({
    super.key,
    this.title = 'Unable to connect',
    this.subtitle =
        "We're having trouble reaching our servers. Please check your connection and try again.",
    this.icon = Icons.cloud_off_outlined,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  /// Network connectivity error.
  const SmoothErrorScreen.network({super.key, this.onRetry})
      : title = 'Unable to connect',
        subtitle =
            "We're having trouble reaching our servers. Please check your connection and try again.",
        icon = Icons.cloud_off_outlined,
        retryLabel = 'Try again';

  /// Generic unexpected error.
  const SmoothErrorScreen.unexpected({super.key, this.onRetry})
      : title = 'Something went wrong',
        subtitle = 'An unexpected error occurred. Please try again.',
        icon = Icons.error_outline,
        retryLabel = 'Try again';

  /// Resource not found.
  const SmoothErrorScreen.notFound({super.key, this.onRetry})
      : title = 'Not found',
        subtitle = "The page or resource you're looking for doesn't exist.",
        icon = Icons.search_off_outlined,
        retryLabel = 'Go back';

  /// Empty state — no data to show.
  const SmoothErrorScreen.empty({
    super.key,
    this.onRetry,
    this.title = 'Nothing here yet',
    this.subtitle = 'There is no data to display.',
  })  : icon = Icons.inbox_outlined,
        retryLabel = 'Refresh';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(160, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// An inline error card for displaying data errors or empty states within a page.
///
/// Supports [compact] mode for tight spaces (renders as a single row)
/// and full mode (centered column with icon, title, subtitle, retry).
class SmoothErrorCard extends StatelessWidget {
  /// The main error message.
  final String title;

  /// An optional longer description.
  final String? subtitle;

  /// The icon shown alongside the error.
  final IconData icon;

  /// Called when the retry button is tapped. If null, no retry is shown.
  final VoidCallback? onRetry;

  /// Tint color for the icon. Defaults to grey.
  final Color? iconColor;

  /// When true, renders as a compact single-row layout.
  final bool compact;

  const SmoothErrorCard({
    super.key,
    this.title = 'Data unavailable',
    this.subtitle,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.iconColor,
    this.compact = false,
  });

  /// Network or connectivity error.
  factory SmoothErrorCard.network({
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return SmoothErrorCard(
      title: 'Connection error',
      subtitle: 'Please check your internet connection',
      icon: Icons.wifi_off_outlined,
      onRetry: onRetry,
      iconColor: Colors.orange,
      compact: compact,
    );
  }

  /// Resource not found.
  factory SmoothErrorCard.notFound({bool compact = false}) {
    return SmoothErrorCard(
      title: 'Not found',
      subtitle: 'The requested data could not be found',
      icon: Icons.search_off_outlined,
      compact: compact,
    );
  }

  /// Generic unexpected error.
  factory SmoothErrorCard.unexpected({
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return SmoothErrorCard(
      title: 'Something went wrong',
      subtitle: 'An unexpected error occurred',
      icon: Icons.error_outline,
      onRetry: onRetry,
      compact: compact,
    );
  }

  /// Empty state — no data to display.
  factory SmoothErrorCard.empty({
    String title = 'Nothing here yet',
    String? subtitle,
    bool compact = false,
  }) {
    return SmoothErrorCard(
      title: title,
      subtitle: subtitle,
      icon: Icons.inbox_outlined,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey[500]),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Retry',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    (iconColor ?? Colors.grey[400])?.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(icon, size: 32, color: iconColor ?? Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
