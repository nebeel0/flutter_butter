import 'package:flutter_test/flutter_test.dart';
import 'package:road_map/road_map.dart';

/// Builds a simple linear DAG: A -> B -> C
/// A and B have one validation item each. C has none (auto-completes).
RoadMapData _linearDag() {
  return RoadMapData(
    label: 'Linear',
    nodes: const [
      RoadMapNode(
        id: 'a',
        label: 'A',
        validationItems: [ValidationItem(id: 'a1', label: 'Check A')],
      ),
      RoadMapNode(
        id: 'b',
        label: 'B',
        validationItems: [ValidationItem(id: 'b1', label: 'Check B')],
      ),
      RoadMapNode(id: 'c', label: 'C'),
    ],
    edges: const [
      RoadMapEdge(source: 'a', target: 'b'),
      RoadMapEdge(source: 'b', target: 'c'),
    ],
  );
}

/// Builds a diamond DAG:
///   A
///  / \
/// B   C
///  \ /
///   D
RoadMapData _diamondDag() {
  return RoadMapData(
    nodes: const [
      RoadMapNode(
        id: 'a',
        label: 'A',
        validationItems: [ValidationItem(id: 'a1', label: 'Check A')],
      ),
      RoadMapNode(
        id: 'b',
        label: 'B',
        validationItems: [ValidationItem(id: 'b1', label: 'Check B')],
      ),
      RoadMapNode(
        id: 'c',
        label: 'C',
        validationItems: [ValidationItem(id: 'c1', label: 'Check C')],
      ),
      RoadMapNode(
        id: 'd',
        label: 'D',
        validationItems: [ValidationItem(id: 'd1', label: 'Check D')],
      ),
    ],
    edges: const [
      RoadMapEdge(source: 'a', target: 'b'),
      RoadMapEdge(source: 'a', target: 'c'),
      RoadMapEdge(source: 'b', target: 'd'),
      RoadMapEdge(source: 'c', target: 'd'),
    ],
  );
}

void main() {
  group('Construction', () {
    test('constructs with valid DAG', () {
      final controller = RoadMapController(data: _linearDag());
      expect(controller.data.nodes.length, 3);
      controller.dispose();
    });

    test('throws on cyclic graph', () {
      expect(
        () => RoadMapController(
          data: RoadMapData(
            nodes: const [
              RoadMapNode(id: 'a', label: 'A'),
              RoadMapNode(id: 'b', label: 'B'),
            ],
            edges: const [
              RoadMapEdge(source: 'a', target: 'b'),
              RoadMapEdge(source: 'b', target: 'a'),
            ],
          ),
        ),
        throwsA(isA<RoadMapCycleException>()),
      );
    });

    test('starts on first root node', () {
      final controller = RoadMapController(data: _linearDag());
      expect(controller.currentNodeId, 'a');
      controller.dispose();
    });

    test('handles empty graph', () {
      final controller = RoadMapController(data: RoadMapData(nodes: const []));
      expect(controller.data.nodes, isEmpty);
      controller.dispose();
    });
  });

  group('Root nodes', () {
    test('identifies root nodes (no incoming edges)', () {
      final controller = RoadMapController(data: _linearDag());
      final roots = controller.rootNodes;
      expect(roots.length, 1);
      expect(roots.first.id, 'a');
      controller.dispose();
    });

    test('multiple roots', () {
      final controller = RoadMapController(
        data: RoadMapData(
          nodes: const [
            RoadMapNode(id: 'a', label: 'A'),
            RoadMapNode(id: 'b', label: 'B'),
          ],
        ),
      );
      expect(controller.rootNodes.length, 2);
      controller.dispose();
    });
  });

  group('Status computation', () {
    test('root node with items is ready', () {
      final controller = RoadMapController(data: _linearDag());
      expect(controller.statusOf('a'), NodeStatus.ready);
      controller.dispose();
    });

    test('node with incomplete prerequisites is blocked', () {
      final controller = RoadMapController(data: _linearDag());
      expect(controller.statusOf('b'), NodeStatus.blocked);
      controller.dispose();
    });

    test('node with no items auto-completes when prerequisites met', () {
      final controller = RoadMapController(data: _linearDag());
      // Complete A and B to unblock C (which has no items).
      controller.setValidationItemComplete('a', 'a1', true);
      controller.setValidationItemComplete('b', 'b1', true);
      expect(controller.statusOf('c'), NodeStatus.complete);
      controller.dispose();
    });

    test('completing all items makes node complete', () {
      final controller = RoadMapController(data: _linearDag());
      controller.setValidationItemComplete('a', 'a1', true);
      expect(controller.statusOf('a'), NodeStatus.complete);
      controller.dispose();
    });

    test('diamond DAG: D is blocked until both B and C are complete', () {
      final controller = RoadMapController(data: _diamondDag());
      controller.setValidationItemComplete('a', 'a1', true);
      controller.setValidationItemComplete('b', 'b1', true);
      // C is still incomplete, so D should be blocked.
      expect(controller.statusOf('d'), NodeStatus.blocked);

      controller.setValidationItemComplete('c', 'c1', true);
      // Now D should be ready.
      expect(controller.statusOf('d'), NodeStatus.ready);
      controller.dispose();
    });
  });

  group('Validation state propagation', () {
    test('completing prerequisite unblocks dependent', () {
      final controller = RoadMapController(data: _linearDag());
      expect(controller.statusOf('b'), NodeStatus.blocked);

      controller.setValidationItemComplete('a', 'a1', true);
      expect(controller.statusOf('b'), NodeStatus.ready);
      controller.dispose();
    });

    test('unchecking item cascades revert to blocked', () {
      final controller = RoadMapController(data: _linearDag());
      // Complete A.
      controller.setValidationItemComplete('a', 'a1', true);
      expect(controller.statusOf('b'), NodeStatus.ready);

      // Un-complete A.
      controller.setValidationItemComplete('a', 'a1', false);
      expect(controller.statusOf('a'), NodeStatus.ready);
      expect(controller.statusOf('b'), NodeStatus.blocked);
      controller.dispose();
    });

    test('deep cascade: unchecking A reverts B and C', () {
      final controller = RoadMapController(data: _linearDag());
      // Complete everything.
      controller.setValidationItemComplete('a', 'a1', true);
      controller.setValidationItemComplete('b', 'b1', true);
      expect(controller.statusOf('c'), NodeStatus.complete);

      // Un-complete A.
      controller.setValidationItemComplete('a', 'a1', false);
      expect(controller.statusOf('a'), NodeStatus.ready);
      expect(controller.statusOf('b'), NodeStatus.blocked);
      expect(controller.statusOf('c'), NodeStatus.blocked);
      controller.dispose();
    });

    test('throws on unknown node ID', () {
      final controller = RoadMapController(data: _linearDag());
      expect(
        () => controller.setValidationItemComplete('unknown', 'v1', true),
        throwsA(isA<ArgumentError>()),
      );
      controller.dispose();
    });

    test('throws on unknown item ID', () {
      final controller = RoadMapController(data: _linearDag());
      expect(
        () => controller.setValidationItemComplete('a', 'unknown', true),
        throwsA(isA<ArgumentError>()),
      );
      controller.dispose();
    });

    test('no-op when setting same value', () {
      final controller = RoadMapController(data: _linearDag());
      var notified = false;
      controller.addListener(() => notified = true);

      controller.setValidationItemComplete('a', 'a1', false);
      expect(notified, false);
      controller.dispose();
    });
  });

  group('Total progress', () {
    test('empty graph returns 0', () {
      final controller = RoadMapController(data: RoadMapData(nodes: const []));
      expect(controller.totalProgress, 0.0);
      controller.dispose();
    });

    test('correct ratio', () {
      final controller = RoadMapController(data: _linearDag());
      // Initially: A=ready, B=blocked, C=blocked. 0/3 complete.
      expect(controller.totalProgress, 0.0);

      // Complete A -> A=complete, B=ready, C=blocked. 1/3.
      controller.setValidationItemComplete('a', 'a1', true);
      expect(controller.totalProgress, closeTo(1 / 3, 0.01));

      // Complete B -> C auto-completes (no items). 3/3.
      controller.setValidationItemComplete('b', 'b1', true);
      expect(controller.totalProgress, 1.0);
      controller.dispose();
    });
  });

  group('Navigation', () {
    test('navigateTo changes current node', () {
      final controller = RoadMapController(data: _linearDag());
      controller.navigateTo('b');
      expect(controller.currentNodeId, 'b');
      expect(controller.currentNode.id, 'b');
      controller.dispose();
    });

    test('navigateTo throws on unknown ID', () {
      final controller = RoadMapController(data: _linearDag());
      expect(
        () => controller.navigateTo('unknown'),
        throwsA(isA<ArgumentError>()),
      );
      controller.dispose();
    });

    test('navigateTo to same node is a no-op', () {
      final controller = RoadMapController(data: _linearDag());
      var notified = false;
      controller.addListener(() => notified = true);

      controller.navigateTo('a');
      expect(notified, false);
      controller.dispose();
    });

    test('goBack returns to previous node', () {
      final controller = RoadMapController(data: _linearDag());
      controller.navigateTo('b');
      controller.navigateTo('c');
      expect(controller.currentNodeId, 'c');

      controller.goBack();
      expect(controller.currentNodeId, 'b');

      controller.goBack();
      expect(controller.currentNodeId, 'a');
      controller.dispose();
    });

    test('canGoBack is false at start', () {
      final controller = RoadMapController(data: _linearDag());
      expect(controller.canGoBack, false);
      controller.dispose();
    });

    test('canGoBack is true after navigation', () {
      final controller = RoadMapController(data: _linearDag());
      controller.navigateTo('b');
      expect(controller.canGoBack, true);
      controller.dispose();
    });

    test('goBack does nothing when cannot go back', () {
      final controller = RoadMapController(data: _linearDag());
      var notified = false;
      controller.addListener(() => notified = true);

      controller.goBack();
      expect(notified, false);
      expect(controller.currentNodeId, 'a');
      controller.dispose();
    });

    test('navigating after goBack truncates forward history', () {
      final controller = RoadMapController(data: _linearDag());
      controller.navigateTo('b');
      controller.navigateTo('c');
      controller.goBack(); // back to b
      controller.navigateTo('a'); // should truncate forward to c

      controller.goBack();
      expect(controller.currentNodeId, 'b');

      // No forward to c anymore.
      controller.goBack();
      expect(controller.currentNodeId, 'a');
      expect(controller.canGoBack, false);
      controller.dispose();
    });
  });

  group('Parents and children', () {
    test('parentsOf returns prerequisite nodes', () {
      final controller = RoadMapController(data: _linearDag());
      final parents = controller.parentsOf('b');
      expect(parents.length, 1);
      expect(parents.first.id, 'a');
      controller.dispose();
    });

    test('childrenOf returns dependent nodes', () {
      final controller = RoadMapController(data: _linearDag());
      final children = controller.childrenOf('a');
      expect(children.length, 1);
      expect(children.first.id, 'b');
      controller.dispose();
    });

    test('diamond DAG: D has two parents', () {
      final controller = RoadMapController(data: _diamondDag());
      final parents = controller.parentsOf('d');
      expect(parents.length, 2);
      expect(parents.map((n) => n.id).toSet(), {'b', 'c'});
      controller.dispose();
    });

    test('root has no parents', () {
      final controller = RoadMapController(data: _linearDag());
      expect(controller.parentsOf('a'), isEmpty);
      controller.dispose();
    });

    test('leaf has no children', () {
      final controller = RoadMapController(data: _linearDag());
      expect(controller.childrenOf('c'), isEmpty);
      controller.dispose();
    });
  });

  group('updateData', () {
    test('replaces graph and recomputes state', () {
      final controller = RoadMapController(data: _linearDag());
      controller.setValidationItemComplete('a', 'a1', true);

      // Replace with diamond DAG.
      controller.updateData(_diamondDag());

      expect(controller.data.nodes.length, 4);
      expect(controller.statusOf('a'), NodeStatus.ready);
      controller.dispose();
    });

    test('stays on current node if it exists in new data', () {
      final controller = RoadMapController(data: _linearDag());
      controller.navigateTo('b');

      // Update with data that still has node b.
      controller.updateData(_diamondDag());
      expect(controller.currentNodeId, 'b');
      controller.dispose();
    });

    test('resets to root if current node does not exist in new data', () {
      final controller = RoadMapController(data: _linearDag());
      controller.navigateTo('c');

      // Update with diamond DAG which doesn't have node 'c' -> wait, it does
      // have 'c'. Let's use a different data set.
      controller.updateData(
        RoadMapData(
          nodes: const [
            RoadMapNode(id: 'x', label: 'X'),
            RoadMapNode(id: 'y', label: 'Y'),
          ],
          edges: const [RoadMapEdge(source: 'x', target: 'y')],
        ),
      );

      expect(controller.currentNodeId, 'x');
      controller.dispose();
    });

    test('throws on cyclic new data', () {
      final controller = RoadMapController(data: _linearDag());
      expect(
        () => controller.updateData(
          RoadMapData(
            nodes: const [
              RoadMapNode(id: 'a', label: 'A'),
              RoadMapNode(id: 'b', label: 'B'),
            ],
            edges: const [
              RoadMapEdge(source: 'a', target: 'b'),
              RoadMapEdge(source: 'b', target: 'a'),
            ],
          ),
        ),
        throwsA(isA<RoadMapCycleException>()),
      );
      controller.dispose();
    });
  });

  group('Notification', () {
    test('notifies on navigateTo', () {
      final controller = RoadMapController(data: _linearDag());
      var count = 0;
      controller.addListener(() => count++);

      controller.navigateTo('b');
      expect(count, 1);
      controller.dispose();
    });

    test('notifies on setValidationItemComplete', () {
      final controller = RoadMapController(data: _linearDag());
      var count = 0;
      controller.addListener(() => count++);

      controller.setValidationItemComplete('a', 'a1', true);
      expect(count, 1);
      controller.dispose();
    });

    test('notifies on goBack', () {
      final controller = RoadMapController(data: _linearDag());
      controller.navigateTo('b');

      var count = 0;
      controller.addListener(() => count++);

      controller.goBack();
      expect(count, 1);
      controller.dispose();
    });

    test('notifies on updateData', () {
      final controller = RoadMapController(data: _linearDag());
      var count = 0;
      controller.addListener(() => count++);

      controller.updateData(_diamondDag());
      expect(count, 1);
      controller.dispose();
    });
  });
}
