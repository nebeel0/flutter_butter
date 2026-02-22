import 'package:flutter/material.dart';

import '../butter_chat_style.dart';
import '../models/butter_suggestion.dart';
import 'butter_suggestion_card.dart';

/// Placeholder shown when the chat is empty.
class ButterWelcomePlaceholder extends StatefulWidget {
  const ButterWelcomePlaceholder({
    super.key,
    this.title = 'How can I help you today?',
    this.subtitle,
    this.icon,
    this.suggestions,
    this.onSuggestionTap,
    this.suggestionStyle,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Suggestion prompts displayed below the greeting.
  final List<ButterSuggestion>? suggestions;

  /// Called when a suggestion card is tapped.
  final ValueChanged<ButterSuggestion>? onSuggestionTap;
  final ButterSuggestionStyle? suggestionStyle;

  @override
  State<ButterWelcomePlaceholder> createState() =>
      _ButterWelcomePlaceholderState();
}

class _ButterWelcomePlaceholderState extends State<ButterWelcomePlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300 + (widget.suggestions?.length ?? 0) * 60,
      ),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final suggestions = widget.suggestions;
    final hasSuggestions = suggestions != null && suggestions.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon ?? Icons.chat_bubble_outline,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (hasSuggestions) ...[
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var i = 0; i < suggestions.length; i++)
                      _StaggeredFadeIn(
                        animation: _animController,
                        delayFraction: i * 0.15,
                        child: ButterSuggestionCard(
                          suggestion: suggestions[i],
                          onTap: () =>
                              widget.onSuggestionTap?.call(suggestions[i]),
                          style: widget.suggestionStyle,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StaggeredFadeIn extends StatelessWidget {
  const _StaggeredFadeIn({
    required this.animation,
    required this.delayFraction,
    required this.child,
  });

  final Animation<double> animation;
  final double delayFraction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final begin = delayFraction.clamp(0.0, 0.8);
    final end = (begin + 0.4).clamp(0.0, 1.0);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
