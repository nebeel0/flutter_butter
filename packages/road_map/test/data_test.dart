import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:road_map/road_map.dart';

void main() {
  group('ValidationItem', () {
    test('constructs with defaults', () {
      const item = ValidationItem(id: 'v1', label: 'Check it');
      expect(item.id, 'v1');
      expect(item.label, 'Check it');
      expect(item.isComplete, false);
    });

    test('copyWith replaces fields', () {
      const item = ValidationItem(id: 'v1', label: 'Check it');
      final updated = item.copyWith(isComplete: true);
      expect(updated.isComplete, true);
      expect(updated.id, 'v1');
    });

    test('equality and hashCode', () {
      const a = ValidationItem(id: 'v1', label: 'Check it');
      const b = ValidationItem(id: 'v1', label: 'Check it');
      const c = ValidationItem(id: 'v2', label: 'Check it');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('JSON roundtrip', () {
      const item =
          ValidationItem(id: 'v1', label: 'Check it', isComplete: true);
      final json = item.toJson();
      final restored = ValidationItem.fromJson(json);
      expect(restored, equals(item));
    });

    test('fromJson handles missing isComplete', () {
      final item = ValidationItem.fromJson({'id': 'v1', 'label': 'Test'});
      expect(item.isComplete, false);
    });
  });

  group('RoadMapNode', () {
    test('constructs with defaults', () {
      const node = RoadMapNode(id: 'n1', label: 'Node 1');
      expect(node.id, 'n1');
      expect(node.label, 'Node 1');
      expect(node.content, '');
      expect(node.validationItems, isEmpty);
    });

    test('equality includes validation items', () {
      const a = RoadMapNode(
        id: 'n1',
        label: 'Node 1',
        validationItems: [ValidationItem(id: 'v1', label: 'Check')],
      );
      const b = RoadMapNode(
        id: 'n1',
        label: 'Node 1',
        validationItems: [ValidationItem(id: 'v1', label: 'Check')],
      );
      expect(a, equals(b));
    });

    test('JSON roundtrip', () {
      const node = RoadMapNode(
        id: 'n1',
        label: 'Node 1',
        content: '# Hello',
        validationItems: [
          ValidationItem(id: 'v1', label: 'Check 1', isComplete: true),
          ValidationItem(id: 'v2', label: 'Check 2'),
        ],
      );
      final json = node.toJson();
      final restored = RoadMapNode.fromJson(json);
      expect(restored, equals(node));
    });

    test('fromJson handles missing optional fields', () {
      final node = RoadMapNode.fromJson({'id': 'n1', 'label': 'Node 1'});
      expect(node.content, '');
      expect(node.validationItems, isEmpty);
    });
  });

  group('RoadMapEdge', () {
    test('constructs', () {
      const edge = RoadMapEdge(source: 'a', target: 'b');
      expect(edge.source, 'a');
      expect(edge.target, 'b');
    });

    test('equality', () {
      const a = RoadMapEdge(source: 'a', target: 'b');
      const b = RoadMapEdge(source: 'a', target: 'b');
      const c = RoadMapEdge(source: 'b', target: 'a');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('JSON roundtrip', () {
      const edge = RoadMapEdge(source: 'a', target: 'b');
      final json = edge.toJson();
      final restored = RoadMapEdge.fromJson(json);
      expect(restored, equals(edge));
    });
  });

  group('RoadMapData', () {
    test('constructs with valid data', () {
      final data = RoadMapData(
        label: 'Test',
        nodes: const [
          RoadMapNode(id: 'a', label: 'A'),
          RoadMapNode(id: 'b', label: 'B'),
        ],
        edges: const [RoadMapEdge(source: 'a', target: 'b')],
      );
      expect(data.nodes.length, 2);
      expect(data.edges.length, 1);
      expect(data.label, 'Test');
    });

    test('throws on duplicate node IDs', () {
      expect(
        () => RoadMapData(
          nodes: const [
            RoadMapNode(id: 'a', label: 'A'),
            RoadMapNode(id: 'a', label: 'A again'),
          ],
        ),
        throwsA(isA<RoadMapFormatException>()),
      );
    });

    test('throws on dangling source edge', () {
      expect(
        () => RoadMapData(
          nodes: const [RoadMapNode(id: 'a', label: 'A')],
          edges: const [RoadMapEdge(source: 'nonexistent', target: 'a')],
        ),
        throwsA(isA<RoadMapFormatException>()),
      );
    });

    test('throws on dangling target edge', () {
      expect(
        () => RoadMapData(
          nodes: const [RoadMapNode(id: 'a', label: 'A')],
          edges: const [RoadMapEdge(source: 'a', target: 'nonexistent')],
        ),
        throwsA(isA<RoadMapFormatException>()),
      );
    });

    test('JSON roundtrip', () {
      final data = RoadMapData(
        label: 'My Map',
        nodes: const [
          RoadMapNode(id: 'a', label: 'A', content: 'Content A'),
          RoadMapNode(id: 'b', label: 'B'),
        ],
        edges: const [RoadMapEdge(source: 'a', target: 'b')],
      );

      final jsonStr = jsonEncode(data.toJson());
      final restored =
          RoadMapData.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

      expect(restored.label, data.label);
      expect(restored.nodes.length, data.nodes.length);
      expect(restored.edges.length, data.edges.length);
      expect(restored.nodes[0], data.nodes[0]);
      expect(restored.edges[0], data.edges[0]);
    });

    test('equality', () {
      final a = RoadMapData(
        nodes: const [RoadMapNode(id: 'a', label: 'A')],
      );
      final b = RoadMapData(
        nodes: const [RoadMapNode(id: 'a', label: 'A')],
      );
      expect(a, equals(b));
    });

    test('allows empty graph', () {
      final data = RoadMapData(nodes: const []);
      expect(data.nodes, isEmpty);
      expect(data.edges, isEmpty);
    });
  });
}
