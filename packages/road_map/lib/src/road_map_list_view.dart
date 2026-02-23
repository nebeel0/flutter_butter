import 'package:flutter/material.dart';

import 'controller.dart';
import 'data.dart';
import 'style.dart';

/// A flat checklist view of a road map DAG in topological order.
///
/// Each row shows the node label, its parent context, and a status badge.
/// Tapping a row navigates the shared [RoadMapController].
///
/// Use alongside [RoadMap] to provide a complementary overview:
///
/// ```dart
/// RoadMapListView(controller: controller)
/// ```
class RoadMapListView extends StatelessWidget {
  /// Creates a road map list view.
  const RoadMapListView({
    super.key,
    required this.controller,
    this.style = const RoadMapStyle(),
    this.onValidationChange,
    this.onNodeTap,
    this.readOnly = false,
  });

  /// The controller that manages DAG state, navigation, and validation.
  final RoadMapController controller;

  /// Visual styling. Defaults derived from the current theme.
  final RoadMapStyle style;

  /// Called after a validation item is toggled.
  final void Function(String nodeId, String itemId, bool complete)?
  onValidationChange;

  /// Called when a node row is tapped. Defaults to [controller.navigateTo].
  final void Function(String nodeId)? onNodeTap;

  /// When true, interaction is disabled.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final nodes = controller.topologicalOrder;

        if (nodes.isEmpty) {
          return const Center(child: Text('No nodes in road map.'));
        }

        return Material(
          child: ListView.builder(
            itemCount: nodes.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final node = nodes[index];
              final status = controller.statusOf(node.id);
              final isCurrent = node.id == controller.currentNodeId;
              final parents = controller.parentsOf(node.id);

              return _ListItem(
                node: node,
                status: status,
                isCurrent: isCurrent,
                parents: parents,
                style: style,
                onTap: readOnly
                    ? null
                    : () => (onNodeTap ?? controller.navigateTo)(node.id),
              );
            },
          ),
        );
      },
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.node,
    required this.status,
    required this.isCurrent,
    required this.parents,
    required this.style,
    this.onTap,
  });

  final RoadMapNode node;
  final NodeStatus status;
  final bool isCurrent;
  final List<RoadMapNode> parents;
  final RoadMapStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = statusColor(status, style, colorScheme);

    final statusLabel = switch (status) {
      NodeStatus.blocked => 'Blocked',
      NodeStatus.ready => 'Ready',
      NodeStatus.complete => 'Complete',
    };

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isCurrent
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            // Title + parent context
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isCurrent ? FontWeight.bold : null,
                    ),
                  ),
                  if (parents.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '\u2190 ${parents.map((p) => p.label).join(', ')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge chip
            Chip(
              label: Text(
                statusLabel,
                style: TextStyle(color: color, fontSize: 12),
              ),
              backgroundColor: color.withValues(alpha: 0.1),
              side: BorderSide(color: color.withValues(alpha: 0.3)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
