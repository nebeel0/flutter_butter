import 'package:flutter/material.dart';

import 'controller.dart';
import 'data.dart';
import 'style.dart';

/// A document-style DAG navigator widget.
///
/// Each node in the DAG is rendered as a page with title, content,
/// prerequisites, validation checklist, and navigation buttons. A
/// collapsible tree sidebar provides orientation.
///
/// The consumer creates and owns the [RoadMapController]:
///
/// ```dart
/// final controller = RoadMapController(data: myData);
///
/// @override
/// Widget build(BuildContext context) {
///   return RoadMap(controller: controller);
/// }
///
/// @override
/// void dispose() {
///   controller.dispose();
///   super.dispose();
/// }
/// ```
class RoadMap extends StatelessWidget {
  /// Creates a road map navigator.
  const RoadMap({
    super.key,
    required this.controller,
    this.style = const RoadMapStyle(),
    this.nodePageBuilder,
    this.onValidationChange,
    this.initialNodeId,
    this.readOnly = false,
  });

  /// The controller that manages DAG state, navigation, and validation.
  final RoadMapController controller;

  /// Visual styling. Defaults derived from the current theme.
  final RoadMapStyle style;

  /// When provided, replaces the entire default page renderer.
  final Widget Function(
    BuildContext context,
    RoadMapNode node,
    RoadMapController controller,
  )?
  nodePageBuilder;

  /// Called after a validation item is toggled. Use for side effects
  /// (e.g., persisting state, analytics).
  final void Function(String nodeId, String itemId, bool complete)?
  onValidationChange;

  /// Which node to show on first render. Defaults to first root node.
  final String? initialNodeId;

  /// When true, validation checkboxes are non-interactive.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (initialNodeId != null && controller.currentNodeId != initialNodeId) {
      // Navigate to initial node on first build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.currentNodeId != initialNodeId) {
          controller.navigateTo(initialNodeId!);
        }
      });
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.data.nodes.isEmpty) {
          return const Center(child: Text('No nodes in road map.'));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;

            if (isCompact) {
              return _CompactLayout(
                controller: controller,
                style: style,
                nodePageBuilder: nodePageBuilder,
                onValidationChange: onValidationChange,
                readOnly: readOnly,
              );
            }

            return _ExpandedLayout(
              controller: controller,
              style: style,
              sidebarWidth: style.sidebarWidth ?? 260,
              nodePageBuilder: nodePageBuilder,
              onValidationChange: onValidationChange,
              readOnly: readOnly,
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Compact layout: drawer sidebar, full-screen page
// ---------------------------------------------------------------------------

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.controller,
    required this.style,
    this.nodePageBuilder,
    this.onValidationChange,
    required this.readOnly,
  });

  final RoadMapController controller;
  final RoadMapStyle style;
  final Widget Function(BuildContext, RoadMapNode, RoadMapController)?
  nodePageBuilder;
  final void Function(String, String, bool)? onValidationChange;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: controller.canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.goBack,
                tooltip: 'Back',
              )
            : null,
        title: Text(controller.currentNode.label),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              tooltip: 'Open navigation',
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: _Sidebar(
          controller: controller,
          style: style,
          onNodeSelected: (nodeId) {
            controller.navigateTo(nodeId);
            Navigator.of(context).pop(); // close drawer
          },
        ),
      ),
      body: _NodePage(
        controller: controller,
        style: style,
        nodePageBuilder: nodePageBuilder,
        onValidationChange: onValidationChange,
        readOnly: readOnly,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expanded layout: persistent sidebar + page
// ---------------------------------------------------------------------------

class _ExpandedLayout extends StatelessWidget {
  const _ExpandedLayout({
    required this.controller,
    required this.style,
    required this.sidebarWidth,
    this.nodePageBuilder,
    this.onValidationChange,
    required this.readOnly,
  });

  final RoadMapController controller;
  final RoadMapStyle style;
  final double sidebarWidth;
  final Widget Function(BuildContext, RoadMapNode, RoadMapController)?
  nodePageBuilder;
  final void Function(String, String, bool)? onValidationChange;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: controller.canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.goBack,
                tooltip: 'Back',
              )
            : null,
        title: _Breadcrumbs(controller: controller, style: style),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: sidebarWidth,
            child: _Sidebar(
              controller: controller,
              style: style,
              onNodeSelected: controller.navigateTo,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _NodePage(
              controller: controller,
              style: style,
              nodePageBuilder: nodePageBuilder,
              onValidationChange: onValidationChange,
              readOnly: readOnly,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar: tree view with search
// ---------------------------------------------------------------------------

class _Sidebar extends StatefulWidget {
  const _Sidebar({
    required this.controller,
    required this.style,
    required this.onNodeSelected,
  });

  final RoadMapController controller;
  final RoadMapStyle style;
  final void Function(String nodeId) onNodeSelected;

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = widget.style;

    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search nodes...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        // Progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: widget.controller.totalProgress,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(widget.controller.totalProgress * 100).round()}%',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Tree
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 4),
            children: _buildTree(
              widget.controller.rootNodes,
              style,
              colorScheme,
              depth: 0,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTree(
    List<RoadMapNode> nodes,
    RoadMapStyle style,
    ColorScheme colorScheme, {
    required int depth,
  }) {
    final widgets = <Widget>[];
    for (final node in nodes) {
      if (_searchQuery.isNotEmpty &&
          !node.label.toLowerCase().contains(_searchQuery.toLowerCase())) {
        // Still recurse into children in case they match.
        final childWidgets = _buildTree(
          widget.controller.childrenOf(node.id),
          style,
          colorScheme,
          depth: depth + 1,
        );
        widgets.addAll(childWidgets);
        continue;
      }

      final status = widget.controller.statusOf(node.id);
      final isSelected = node.id == widget.controller.currentNodeId;
      final children = widget.controller.childrenOf(node.id);

      final nodeColor = statusColor(status, style, colorScheme);

      widgets.add(
        _SidebarItem(
          node: node,
          depth: depth,
          isSelected: isSelected,
          statusColor: nodeColor,
          status: status,
          textStyle: style.sidebarItemStyle,
          onTap: () => widget.onNodeSelected(node.id),
        ),
      );

      if (children.isNotEmpty) {
        // Auto-expand path to current node, or all in search mode.
        final shouldExpand =
            _searchQuery.isNotEmpty || _isAncestorOfCurrent(node.id);

        if (shouldExpand) {
          widgets.addAll(
            _buildTree(children, style, colorScheme, depth: depth + 1),
          );
        } else {
          widgets.add(
            _ExpandableChildren(
              parentId: node.id,
              children: children,
              controller: widget.controller,
              style: style,
              colorScheme: colorScheme,
              depth: depth + 1,
              onNodeSelected: widget.onNodeSelected,
              isAncestorOfCurrent: _isAncestorOfCurrent,
            ),
          );
        }
      }
    }
    return widgets;
  }

  bool _isAncestorOfCurrent(String nodeId) {
    // Walk up from current node to see if nodeId is an ancestor.
    final visited = <String>{};
    final queue = [widget.controller.currentNodeId];
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (current == nodeId) return true;
      if (!visited.add(current)) continue;
      for (final parent in widget.controller.parentsOf(current)) {
        queue.add(parent.id);
      }
    }
    return false;
  }
}

class _ExpandableChildren extends StatefulWidget {
  const _ExpandableChildren({
    required this.parentId,
    required this.children,
    required this.controller,
    required this.style,
    required this.colorScheme,
    required this.depth,
    required this.onNodeSelected,
    required this.isAncestorOfCurrent,
  });

  final String parentId;
  final List<RoadMapNode> children;
  final RoadMapController controller;
  final RoadMapStyle style;
  final ColorScheme colorScheme;
  final int depth;
  final void Function(String) onNodeSelected;
  final bool Function(String) isAncestorOfCurrent;

  @override
  State<_ExpandableChildren> createState() => _ExpandableChildrenState();
}

class _ExpandableChildrenState extends State<_ExpandableChildren> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return Padding(
        padding: EdgeInsets.only(left: (widget.depth * 16) + 12.0),
        child: InkWell(
          onTap: () => setState(() => _expanded = true),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.expand_more,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.children.length} more...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final widgets = <Widget>[];
    for (final node in widget.children) {
      final status = widget.controller.statusOf(node.id);
      final isSelected = node.id == widget.controller.currentNodeId;
      final nodeColor = statusColor(status, widget.style, widget.colorScheme);

      widgets.add(
        _SidebarItem(
          node: node,
          depth: widget.depth,
          isSelected: isSelected,
          statusColor: nodeColor,
          status: status,
          textStyle: widget.style.sidebarItemStyle,
          onTap: () => widget.onNodeSelected(node.id),
        ),
      );

      final grandchildren = widget.controller.childrenOf(node.id);
      if (grandchildren.isNotEmpty) {
        final shouldExpand = widget.isAncestorOfCurrent(node.id);
        if (shouldExpand) {
          for (final gc in grandchildren) {
            final gcStatus = widget.controller.statusOf(gc.id);
            final gcSelected = gc.id == widget.controller.currentNodeId;
            widgets.add(
              _SidebarItem(
                node: gc,
                depth: widget.depth + 1,
                isSelected: gcSelected,
                statusColor: statusColor(
                  gcStatus,
                  widget.style,
                  widget.colorScheme,
                ),
                status: gcStatus,
                textStyle: widget.style.sidebarItemStyle,
                onTap: () => widget.onNodeSelected(gc.id),
              ),
            );
          }
        } else {
          widgets.add(
            _ExpandableChildren(
              parentId: node.id,
              children: grandchildren,
              controller: widget.controller,
              style: widget.style,
              colorScheme: widget.colorScheme,
              depth: widget.depth + 1,
              onNodeSelected: widget.onNodeSelected,
              isAncestorOfCurrent: widget.isAncestorOfCurrent,
            ),
          );
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.node,
    required this.depth,
    required this.isSelected,
    required this.statusColor,
    required this.status,
    this.textStyle,
    required this.onTap,
  });

  final RoadMapNode node;
  final int depth;
  final bool isSelected;
  final Color statusColor;
  final NodeStatus status;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        padding: EdgeInsets.only(
          left: (depth * 16) + 12.0,
          right: 12,
          top: 8,
          bottom: 8,
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                node.label,
                style: (textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: status == NodeStatus.blocked
                      ? theme.colorScheme.outline
                      : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (status == NodeStatus.complete)
              Icon(Icons.check, size: 16, color: statusColor),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Breadcrumbs
// ---------------------------------------------------------------------------

class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs({required this.controller, required this.style});

  final RoadMapController controller;
  final RoadMapStyle style;

  @override
  Widget build(BuildContext context) {
    final path = _buildPath();
    if (path.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < path.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            if (i < path.length - 1)
              InkWell(
                onTap: () => controller.navigateTo(path[i].id),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    path[i].label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              )
            else
              Text(
                path[i].label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
          ],
        ],
      ),
    );
  }

  /// Builds a path from the first root to the current node via parent chain.
  List<RoadMapNode> _buildPath() {
    final path = <RoadMapNode>[];
    var current = controller.currentNode;
    path.add(current);

    while (true) {
      final parents = controller.parentsOf(current.id);
      if (parents.isEmpty) break;
      current = parents.first; // Follow first parent for breadcrumbs.
      path.add(current);
    }

    return path.reversed.toList();
  }
}

// ---------------------------------------------------------------------------
// Node page
// ---------------------------------------------------------------------------

class _NodePage extends StatelessWidget {
  const _NodePage({
    required this.controller,
    required this.style,
    this.nodePageBuilder,
    this.onValidationChange,
    required this.readOnly,
  });

  final RoadMapController controller;
  final RoadMapStyle style;
  final Widget Function(BuildContext, RoadMapNode, RoadMapController)?
  nodePageBuilder;
  final void Function(String, String, bool)? onValidationChange;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final node = controller.currentNode;

    if (nodePageBuilder != null) {
      return nodePageBuilder!(context, node, controller);
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = controller.statusOf(node.id);
    final parents = controller.parentsOf(node.id);
    final children = controller.childrenOf(node.id);
    final padding = style.pagePadding ?? const EdgeInsets.all(16);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        key: ValueKey(node.id),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            _StatusBadge(status: status, style: style),
            const SizedBox(height: 12),

            // Title
            Text(
              node.label,
              style:
                  style.nodeTitleStyle ??
                  theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Content
            if (node.content.isNotEmpty) ...[
              Text(
                node.content,
                style: style.nodeContentStyle ?? theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
            ],

            // Prerequisites
            if (parents.isNotEmpty) ...[
              Text(
                'Prerequisites',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...parents.map((parent) {
                final parentStatus = controller.statusOf(parent.id);
                return _PrerequisiteItem(
                  node: parent,
                  status: parentStatus,
                  style: style,
                  onTap: () => controller.navigateTo(parent.id),
                );
              }),
              const SizedBox(height: 24),
            ],

            // Validation
            if (node.validationItems.isNotEmpty) ...[
              Text(
                'Validation',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...node.validationItems.map((item) {
                return CheckboxListTile(
                  value: item.isComplete,
                  onChanged: readOnly || status == NodeStatus.blocked
                      ? null
                      : (value) {
                          controller.setValidationItemComplete(
                            node.id,
                            item.id,
                            value ?? false,
                          );
                          onValidationChange?.call(
                            node.id,
                            item.id,
                            value ?? false,
                          );
                        },
                  title: Text(item.label),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: 24),
            ],

            // Navigation buttons
            const Divider(),
            const SizedBox(height: 12),

            // Parent navigation
            if (parents.isNotEmpty) ...[
              Text(
                'Go to prerequisite',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: parents.map((parent) {
                  final parentStatus = controller.statusOf(parent.id);
                  return _NavButton(
                    label: parent.label,
                    status: parentStatus,
                    style: style,
                    icon: Icons.arrow_upward,
                    onPressed: () => controller.navigateTo(parent.id),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Children navigation
            if (children.isNotEmpty) ...[
              Text(
                'Next',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: children.map((child) {
                  final childStatus = controller.statusOf(child.id);
                  return _NavButton(
                    label: child.label,
                    status: childStatus,
                    style: style,
                    icon: Icons.arrow_downward,
                    onPressed: () => controller.navigateTo(child.id),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small widgets
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.style});

  final NodeStatus status;
  final RoadMapStyle style;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = statusColor(status, style, colorScheme);
    final label = switch (status) {
      NodeStatus.blocked => 'Blocked',
      NodeStatus.ready => 'Ready',
      NodeStatus.complete => 'Complete',
    };
    final icon = switch (status) {
      NodeStatus.blocked => Icons.lock_outline,
      NodeStatus.ready => Icons.radio_button_unchecked,
      NodeStatus.complete => Icons.check_circle_outline,
    };

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _PrerequisiteItem extends StatelessWidget {
  const _PrerequisiteItem({
    required this.node,
    required this.status,
    required this.style,
    required this.onTap,
  });

  final RoadMapNode node;
  final NodeStatus status;
  final RoadMapStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = statusColor(status, style, colorScheme);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              status == NodeStatus.complete
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                node.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: status == NodeStatus.complete
                      ? TextDecoration.lineThrough
                      : null,
                  color: status == NodeStatus.complete
                      ? colorScheme.outline
                      : null,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.status,
    required this.style,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final NodeStatus status;
  final RoadMapStyle style;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = statusColor(status, style, colorScheme);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}
