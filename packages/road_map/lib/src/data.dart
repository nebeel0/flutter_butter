import 'package:flutter/foundation.dart';

/// Computed status for a node based on prerequisites and validation.
enum NodeStatus {
  /// One or more prerequisites are incomplete.
  blocked,

  /// All prerequisites complete, but own validation items not all checked.
  ready,

  /// All prerequisites complete AND all own validation items checked.
  complete,
}

/// A single validation criterion on a node.
@immutable
class ValidationItem {
  /// Creates a validation item.
  const ValidationItem({
    required this.id,
    required this.label,
    this.isComplete = false,
  });

  /// Unique identifier for this item within its node.
  final String id;

  /// Human-readable label describing what needs to be validated.
  final String label;

  /// Whether this item has been completed.
  final bool isComplete;

  /// Returns a copy with the given fields replaced.
  ValidationItem copyWith({
    String? id,
    String? label,
    bool? isComplete,
  }) {
    return ValidationItem(
      id: id ?? this.id,
      label: label ?? this.label,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Deserializes from a JSON map.
  factory ValidationItem.fromJson(Map<String, dynamic> json) {
    return ValidationItem(
      id: json['id'] as String,
      label: json['label'] as String,
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'isComplete': isComplete,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          isComplete == other.isComplete;

  @override
  int get hashCode => Object.hash(id, label, isComplete);

  @override
  String toString() =>
      'ValidationItem(id: $id, label: $label, isComplete: $isComplete)';
}

/// A single node in the DAG. Semantically neutral — no forced labels.
@immutable
class RoadMapNode {
  /// Creates a road map node.
  const RoadMapNode({
    required this.id,
    required this.label,
    this.content = '',
    this.validationItems = const [],
  });

  /// Unique identifier for this node.
  final String id;

  /// Human-readable title.
  final String label;

  /// Markdown content rendered by default, or consumed by a custom
  /// [nodePageBuilder].
  final String content;

  /// Validation criteria for this node. A node is considered complete
  /// when all items are checked and all prerequisites are complete.
  final List<ValidationItem> validationItems;

  /// Returns a copy with the given fields replaced.
  RoadMapNode copyWith({
    String? id,
    String? label,
    String? content,
    List<ValidationItem>? validationItems,
  }) {
    return RoadMapNode(
      id: id ?? this.id,
      label: label ?? this.label,
      content: content ?? this.content,
      validationItems: validationItems ?? this.validationItems,
    );
  }

  /// Deserializes from a JSON map.
  factory RoadMapNode.fromJson(Map<String, dynamic> json) {
    return RoadMapNode(
      id: json['id'] as String,
      label: json['label'] as String,
      content: json['content'] as String? ?? '',
      validationItems: (json['validationItems'] as List<dynamic>?)
              ?.map((e) =>
                  ValidationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'content': content,
      'validationItems': validationItems.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoadMapNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          content == other.content &&
          listEquals(validationItems, other.validationItems);

  @override
  int get hashCode => Object.hash(
        id,
        label,
        content,
        Object.hashAll(validationItems),
      );

  @override
  String toString() => 'RoadMapNode(id: $id, label: $label)';
}

/// A directed prerequisite edge from source to target.
///
/// Means: [source] must be complete before [target] can become ready.
@immutable
class RoadMapEdge {
  /// Creates an edge.
  const RoadMapEdge({
    required this.source,
    required this.target,
  });

  /// The ID of the prerequisite node.
  final String source;

  /// The ID of the dependent node.
  final String target;

  /// Deserializes from a JSON map.
  factory RoadMapEdge.fromJson(Map<String, dynamic> json) {
    return RoadMapEdge(
      source: json['source'] as String,
      target: json['target'] as String,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'target': target,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoadMapEdge &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          target == other.target;

  @override
  int get hashCode => Object.hash(source, target);

  @override
  String toString() => 'RoadMapEdge(source: $source, target: $target)';
}

/// Exception thrown when a cycle is detected in the DAG.
class RoadMapCycleException implements Exception {
  /// Creates a cycle exception.
  const RoadMapCycleException([this.message = 'Cycle detected in road map']);

  /// Description of the cycle.
  final String message;

  @override
  String toString() => 'RoadMapCycleException: $message';
}

/// Exception thrown when road map data is invalid.
class RoadMapFormatException implements Exception {
  /// Creates a format exception.
  const RoadMapFormatException(this.message);

  /// Description of the format error.
  final String message;

  @override
  String toString() => 'RoadMapFormatException: $message';
}

/// The complete road map data structure.
///
/// Immutable. Contains all nodes and edges forming a directed acyclic graph.
@immutable
class RoadMapData {
  /// Creates road map data.
  ///
  /// Throws [RoadMapFormatException] if the data is invalid (duplicate IDs,
  /// dangling edge references). Does NOT validate acyclicity — that is done
  /// by [RoadMapController] on construction.
  RoadMapData({
    this.label,
    required List<RoadMapNode> nodes,
    this.edges = const [],
  }) : nodes = List.unmodifiable(nodes) {
    _validate();
  }

  /// Human-readable label for this road map.
  final String? label;

  /// All nodes in the DAG.
  final List<RoadMapNode> nodes;

  /// All directed edges (prerequisites).
  final List<RoadMapEdge> edges;

  void _validate() {
    final nodeIds = <String>{};
    for (final node in nodes) {
      if (!nodeIds.add(node.id)) {
        throw RoadMapFormatException('Duplicate node ID: ${node.id}');
      }
    }
    for (final edge in edges) {
      if (!nodeIds.contains(edge.source)) {
        throw RoadMapFormatException(
            'Edge references non-existent source node: ${edge.source}');
      }
      if (!nodeIds.contains(edge.target)) {
        throw RoadMapFormatException(
            'Edge references non-existent target node: ${edge.target}');
      }
    }
  }

  /// Deserializes from a JSON map.
  factory RoadMapData.fromJson(Map<String, dynamic> json) {
    return RoadMapData(
      label: json['label'] as String?,
      nodes: (json['nodes'] as List<dynamic>)
          .map((e) => RoadMapNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      edges: (json['edges'] as List<dynamic>?)
              ?.map((e) => RoadMapEdge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (label != null) 'label': label,
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'edges': edges.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoadMapData &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          listEquals(nodes, other.nodes) &&
          listEquals(edges, other.edges);

  @override
  int get hashCode => Object.hash(
        label,
        Object.hashAll(nodes),
        Object.hashAll(edges),
      );

  @override
  String toString() =>
      'RoadMapData(label: $label, nodes: ${nodes.length}, edges: ${edges.length})';
}
