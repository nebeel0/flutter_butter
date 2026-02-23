import 'package:flutter/foundation.dart';
import 'package:graphs/graphs.dart' as graphs;

import 'data.dart';

/// Controls navigation, validation state, and status computation for a
/// [RoadMapData] DAG.
///
/// The consumer creates and owns the controller. The [RoadMap] widget
/// listens to it via [ChangeNotifier].
///
/// ```dart
/// final controller = RoadMapController(data: myRoadMapData);
/// // ...
/// controller.dispose();
/// ```
class RoadMapController extends ChangeNotifier {
  /// Creates a controller for the given road map data.
  ///
  /// Validates that the graph is acyclic. Throws [RoadMapCycleException]
  /// if a cycle is detected.
  RoadMapController({required RoadMapData data}) {
    _setData(data);
  }

  late RoadMapData _data;
  String _currentNodeId = '';
  final List<String> _history = [];
  int _historyIndex = -1;

  // Indexed lookups built from _data.
  final Map<String, RoadMapNode> _nodeById = {};
  final Map<String, List<String>> _parentIds = {}; // nodeId -> parent IDs
  final Map<String, List<String>> _childIds = {}; // nodeId -> child IDs
  final Map<String, NodeStatus> _statusCache = {};
  List<RoadMapNode> _topoOrder = [];

  /// The current road map data.
  RoadMapData get data => _data;

  /// The node currently being viewed.
  RoadMapNode get currentNode => _nodeById[_currentNodeId]!;

  /// The ID of the node currently being viewed.
  String get currentNodeId => _currentNodeId;

  /// All nodes in topological sort order.
  ///
  /// Parents always appear before their dependents. Useful for rendering
  /// a flat checklist view of the entire road map.
  List<RoadMapNode> get topologicalOrder => _topoOrder;

  /// All root nodes (nodes with no incoming prerequisite edges).
  List<RoadMapNode> get rootNodes {
    return _data.nodes.where((n) => (_parentIds[n.id] ?? []).isEmpty).toList();
  }

  /// Computes the [NodeStatus] for a given node.
  ///
  /// - [NodeStatus.blocked]: one or more prerequisites are not complete.
  /// - [NodeStatus.ready]: all prerequisites complete, own items not all done.
  /// - [NodeStatus.complete]: all prerequisites complete AND all own items done.
  NodeStatus statusOf(String nodeId) {
    final cached = _statusCache[nodeId];
    if (cached != null) return cached;

    final node = _nodeById[nodeId];
    if (node == null) {
      throw ArgumentError('Unknown node ID: $nodeId');
    }

    final status = _computeStatus(node);
    _statusCache[nodeId] = status;
    return status;
  }

  /// Returns the prerequisite (parent) nodes of the given node.
  List<RoadMapNode> parentsOf(String nodeId) {
    return (_parentIds[nodeId] ?? []).map((id) => _nodeById[id]!).toList();
  }

  /// Returns the dependent (child) nodes of the given node.
  List<RoadMapNode> childrenOf(String nodeId) {
    return (_childIds[nodeId] ?? []).map((id) => _nodeById[id]!).toList();
  }

  /// Overall completion ratio: complete nodes / total nodes (0.0–1.0).
  double get totalProgress {
    if (_data.nodes.isEmpty) return 0.0;
    final completeCount = _data.nodes
        .where((n) => statusOf(n.id) == NodeStatus.complete)
        .length;
    return completeCount / _data.nodes.length;
  }

  /// Navigates to the node with the given [nodeId].
  ///
  /// Pushes to history. Throws [ArgumentError] if the node does not exist.
  void navigateTo(String nodeId) {
    if (!_nodeById.containsKey(nodeId)) {
      throw ArgumentError('Unknown node ID: $nodeId');
    }
    if (_currentNodeId == nodeId) return;

    // Truncate forward history if we navigated back then forward to a new node.
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    _currentNodeId = nodeId;
    _history.add(nodeId);
    _historyIndex = _history.length - 1;
    notifyListeners();
  }

  /// Navigates back to the previous node in history.
  ///
  /// Does nothing if there is no history to go back to.
  void goBack() {
    if (!canGoBack) return;
    _historyIndex--;
    _currentNodeId = _history[_historyIndex];
    notifyListeners();
  }

  /// Whether there is a previous node in history to go back to.
  bool get canGoBack => _historyIndex > 0;

  /// Toggles a validation item's completion state.
  ///
  /// Recomputes [NodeStatus] for the affected node and cascading dependents.
  void setValidationItemComplete(String nodeId, String itemId, bool complete) {
    final node = _nodeById[nodeId];
    if (node == null) {
      throw ArgumentError('Unknown node ID: $nodeId');
    }

    final itemIndex = node.validationItems.indexWhere(
      (item) => item.id == itemId,
    );
    if (itemIndex == -1) {
      throw ArgumentError(
        'Unknown validation item ID: $itemId on node $nodeId',
      );
    }

    final currentItem = node.validationItems[itemIndex];
    if (currentItem.isComplete == complete) return;

    // Build new validation items list.
    final newItems = List<ValidationItem>.from(node.validationItems);
    newItems[itemIndex] = currentItem.copyWith(isComplete: complete);

    final newNode = node.copyWith(validationItems: newItems);

    // Update the node in data.
    final newNodes = _data.nodes
        .map((n) => n.id == nodeId ? newNode : n)
        .toList();
    _data = RoadMapData(
      label: _data.label,
      nodes: newNodes,
      edges: _data.edges,
    );
    _nodeById[nodeId] = newNode;

    // Recompute status for this node and cascade.
    _invalidateStatusCascade(nodeId);
    notifyListeners();
  }

  /// Replaces the entire road map data and recomputes all state.
  ///
  /// Validates acyclicity. Throws [RoadMapCycleException] if a cycle exists.
  /// Resets navigation to the first root node if the current node no longer
  /// exists.
  void updateData(RoadMapData newData) {
    final previousNodeId = _currentNodeId;
    _setData(newData);

    // Try to stay on the same node if it still exists.
    if (_nodeById.containsKey(previousNodeId)) {
      _currentNodeId = previousNodeId;
    }

    notifyListeners();
  }

  // --- Private implementation ---

  void _setData(RoadMapData newData) {
    _data = newData;
    _nodeById.clear();
    _parentIds.clear();
    _childIds.clear();
    _statusCache.clear();

    for (final node in newData.nodes) {
      _nodeById[node.id] = node;
      _parentIds[node.id] = [];
      _childIds[node.id] = [];
    }

    for (final edge in newData.edges) {
      _parentIds[edge.target]!.add(edge.source);
      _childIds[edge.source]!.add(edge.target);
    }

    _validateAcyclic();

    // Set initial current node: first root, or first node if no roots.
    if (newData.nodes.isNotEmpty) {
      final roots = rootNodes;
      _currentNodeId = roots.isNotEmpty
          ? roots.first.id
          : newData.nodes.first.id;
      _history.clear();
      _history.add(_currentNodeId);
      _historyIndex = 0;
    }
  }

  void _validateAcyclic() {
    if (_data.nodes.isEmpty) {
      _topoOrder = [];
      return;
    }

    try {
      final sortedIds = graphs.topologicalSort<String>(
        _data.nodes.map((n) => n.id),
        (String nodeId) => _childIds[nodeId] ?? <String>[],
      );
      _topoOrder = sortedIds.map((id) => _nodeById[id]!).toList();
    } on graphs.CycleException {
      throw const RoadMapCycleException();
    }
  }

  NodeStatus _computeStatus(RoadMapNode node) {
    // Check if all prerequisites are complete.
    final parents = _parentIds[node.id] ?? [];
    for (final parentId in parents) {
      if (statusOf(parentId) != NodeStatus.complete) {
        return NodeStatus.blocked;
      }
    }

    // All prerequisites met. Check own validation items.
    if (node.validationItems.isEmpty) {
      // No validation items means the node is auto-complete when prerequisites
      // are met.
      return NodeStatus.complete;
    }

    final allItemsComplete = node.validationItems.every(
      (item) => item.isComplete,
    );
    return allItemsComplete ? NodeStatus.complete : NodeStatus.ready;
  }

  /// Invalidates the status cache for [nodeId] and all reachable dependents.
  void _invalidateStatusCascade(String nodeId) {
    _statusCache.remove(nodeId);
    for (final childId in _childIds[nodeId] ?? <String>[]) {
      // Only cascade if the child's cached status might change.
      if (_statusCache.containsKey(childId)) {
        _invalidateStatusCascade(childId);
      }
    }
  }
}
