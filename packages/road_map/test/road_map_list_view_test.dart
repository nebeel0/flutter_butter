import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_map/road_map.dart';

Widget _app({required Widget child}) {
  return MaterialApp(home: Scaffold(body: child));
}

/// Linear DAG: A -> B -> C
RoadMapData _sampleData() {
  return RoadMapData(
    label: 'Test',
    nodes: const [
      RoadMapNode(
        id: 'a',
        label: 'Node A',
        validationItems: [ValidationItem(id: 'a1', label: 'Check A')],
      ),
      RoadMapNode(
        id: 'b',
        label: 'Node B',
        validationItems: [ValidationItem(id: 'b1', label: 'Check B')],
      ),
      RoadMapNode(id: 'c', label: 'Node C'),
    ],
    edges: const [
      RoadMapEdge(source: 'a', target: 'b'),
      RoadMapEdge(source: 'b', target: 'c'),
    ],
  );
}

void main() {
  group('RoadMapListView', () {
    testWidgets('renders all nodes in topological order', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(
        _app(child: RoadMapListView(controller: controller)),
      );

      expect(find.text('Node A'), findsOneWidget);
      expect(find.text('Node B'), findsOneWidget);
      expect(find.text('Node C'), findsOneWidget);

      // Verify ordering: A should appear before B which appears before C.
      final aPos = tester.getTopLeft(find.text('Node A'));
      final bPos = tester.getTopLeft(find.text('Node B'));
      final cPos = tester.getTopLeft(find.text('Node C'));
      expect(aPos.dy, lessThan(bPos.dy));
      expect(bPos.dy, lessThan(cPos.dy));

      controller.dispose();
    });

    testWidgets('shows parent context on non-root nodes', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(
        _app(child: RoadMapListView(controller: controller)),
      );

      // Node A is root, should have no parent context.
      expect(find.text('\u2190 Node A'), findsOneWidget); // B's parent
      expect(find.text('\u2190 Node B'), findsOneWidget); // C's parent

      controller.dispose();
    });

    testWidgets('shows status badges', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(
        _app(child: RoadMapListView(controller: controller)),
      );

      // A is ready, B and C are blocked.
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Blocked'), findsNWidgets(2));

      controller.dispose();
    });

    testWidgets('tapping node navigates controller', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(
        _app(child: RoadMapListView(controller: controller)),
      );

      expect(controller.currentNodeId, 'a');

      await tester.tap(find.text('Node B'));
      await tester.pumpAndSettle();

      expect(controller.currentNodeId, 'b');

      controller.dispose();
    });

    testWidgets('highlights current node', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(
        _app(child: RoadMapListView(controller: controller)),
      );

      // Current node (A) should have bold text.
      final textWidget = tester.widget<Text>(find.text('Node A'));
      expect(textWidget.style?.fontWeight, FontWeight.bold);

      // Non-current node (B) should not be bold.
      final bTextWidget = tester.widget<Text>(find.text('Node B'));
      expect(bTextWidget.style?.fontWeight, isNot(FontWeight.bold));

      controller.dispose();
    });

    testWidgets('onNodeTap custom callback overrides default', (tester) async {
      final controller = RoadMapController(data: _sampleData());
      String? tappedNodeId;

      await tester.pumpWidget(
        _app(
          child: RoadMapListView(
            controller: controller,
            onNodeTap: (nodeId) => tappedNodeId = nodeId,
          ),
        ),
      );

      await tester.tap(find.text('Node B'));
      await tester.pumpAndSettle();

      expect(tappedNodeId, 'b');
      // Controller should NOT have navigated since custom callback was used.
      expect(controller.currentNodeId, 'a');

      controller.dispose();
    });

    testWidgets('readOnly mode disables taps', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(
        _app(child: RoadMapListView(controller: controller, readOnly: true)),
      );

      await tester.tap(find.text('Node B'));
      await tester.pumpAndSettle();

      // Should not navigate because readOnly is true.
      expect(controller.currentNodeId, 'a');

      controller.dispose();
    });

    testWidgets('empty graph shows placeholder', (tester) async {
      final controller = RoadMapController(data: RoadMapData(nodes: const []));

      await tester.pumpWidget(
        _app(child: RoadMapListView(controller: controller)),
      );

      expect(find.text('No nodes in road map.'), findsOneWidget);

      controller.dispose();
    });
  });
}
