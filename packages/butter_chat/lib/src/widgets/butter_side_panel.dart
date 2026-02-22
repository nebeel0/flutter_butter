import 'package:flutter/material.dart';

import '../butter_chat_style.dart';
import '../models/butter_chat_session.dart';
import 'butter_session_tile.dart';

/// A side panel displaying a list of chat sessions with search and actions.
///
/// When [onSearchChanged] is null, built-in filtering by title/subtitle is used.
class ButterSidePanel extends StatefulWidget {
  const ButterSidePanel({
    super.key,
    required this.sessions,
    this.activeSessionId,
    required this.onSessionTap,
    this.onNewChat,
    this.onDeleteSession,
    this.onRenameSession,
    this.onPinSession,
    this.onSearchChanged,
    this.sessionBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.style,
    this.showSearch = true,
  });

  final List<ButterChatSession> sessions;
  final String? activeSessionId;
  final ValueChanged<ButterChatSession> onSessionTap;
  final VoidCallback? onNewChat;
  final ValueChanged<ButterChatSession>? onDeleteSession;
  final void Function(ButterChatSession session, String newTitle)?
      onRenameSession;
  final ValueChanged<ButterChatSession>? onPinSession;

  /// External search handler. When null, built-in filtering is used.
  final ValueChanged<String>? onSearchChanged;

  /// Custom session tile builder.
  final Widget Function(
          BuildContext context, ButterChatSession session, bool isActive)?
      sessionBuilder;

  final WidgetBuilder? headerBuilder;
  final WidgetBuilder? footerBuilder;
  final ButterSidePanelStyle? style;
  final bool showSearch;

  @override
  State<ButterSidePanel> createState() => _ButterSidePanelState();
}

class _ButterSidePanelState extends State<ButterSidePanel> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!(value);
    } else {
      setState(() => _searchQuery = value.toLowerCase());
    }
  }

  List<ButterChatSession> get _filteredSessions {
    var sessions = widget.sessions;

    // Apply built-in filtering when no external handler.
    if (widget.onSearchChanged == null && _searchQuery.isNotEmpty) {
      sessions = sessions.where((s) {
        return s.title.toLowerCase().contains(_searchQuery) ||
            (s.subtitle?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Sort: pinned first, then by updatedAt descending.
    sessions = List.of(sessions)
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        final aTime = a.updatedAt ?? a.createdAt;
        final bTime = b.updatedAt ?? b.createdAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = widget.style;
    final searchStyle = style?.searchBarStyle;

    final bgColor = style?.backgroundColor ?? colorScheme.surfaceContainerLow;
    final headerPadding =
        style?.headerPadding ?? const EdgeInsets.all(12);
    final searchBg =
        searchStyle?.backgroundColor ?? colorScheme.surfaceContainerHighest;
    final searchBorderRadius =
        searchStyle?.borderRadius ?? BorderRadius.circular(8);

    final filtered = _filteredSessions;

    return Container(
      color: bgColor,
      child: Column(
        children: [
          // Header.
          if (widget.headerBuilder != null)
            widget.headerBuilder!(context)
          else
            Padding(
              padding: headerPadding,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chats',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (widget.onNewChat != null)
                    IconButton(
                      onPressed: widget.onNewChat,
                      icon: const Icon(Icons.edit_square, size: 20),
                      tooltip: 'New chat',
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
          // Search bar.
          if (widget.showSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: searchStyle?.textStyle,
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: searchStyle?.hintStyle,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: searchStyle?.iconColor ??
                        colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: searchBg,
                  border: OutlineInputBorder(
                    borderRadius: searchBorderRadius,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  isDense: true,
                ),
              ),
            ),
          if (widget.showSearch) const SizedBox(height: 8),
          // Session list.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final session = filtered[index];
                final isActive = session.id == widget.activeSessionId;

                if (widget.sessionBuilder != null) {
                  return widget.sessionBuilder!(context, session, isActive);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: ButterSessionTile(
                    session: session,
                    isActive: isActive,
                    onTap: () => widget.onSessionTap(session),
                    onDelete: widget.onDeleteSession != null
                        ? () => widget.onDeleteSession!(session)
                        : null,
                    onRename: widget.onRenameSession != null
                        ? (newTitle) =>
                            widget.onRenameSession!(session, newTitle)
                        : null,
                    onPin: widget.onPinSession != null
                        ? () => widget.onPinSession!(session)
                        : null,
                    style: style?.sessionTileStyle,
                  ),
                );
              },
            ),
          ),
          // Footer.
          if (widget.footerBuilder != null) widget.footerBuilder!(context),
        ],
      ),
    );
  }
}
