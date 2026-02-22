import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_map/road_map.dart';

Widget _app({required Widget child, double? width}) {
  final body = width != null
      ? Center(child: SizedBox(width: width, height: 600, child: child))
      : child;
  return MaterialApp(home: body);
}

RoadMapData _sampleData() {
  return RoadMapData(
    label: 'Test Roadmap',
    nodes: const [
      RoadMapNode(
        id: 'setup',
        label: 'Set Up Environment',
        content: 'Install required tools.',
        validationItems: [
          ValidationItem(id: 's1', label: 'IDE installed'),
          ValidationItem(id: 's2', label: 'SDK configured'),
        ],
      ),
      RoadMapNode(
        id: 'clone',
        label: 'Clone Repository',
        content: 'Clone the main repo.',
        validationItems: [
          ValidationItem(id: 'c1', label: 'Repo cloned'),
        ],
      ),
      RoadMapNode(
        id: 'pr',
        label: 'Submit First PR',
        content: 'Pick an issue and submit.',
        validationItems: [
          ValidationItem(id: 'p1', label: 'PR submitted'),
        ],
      ),
    ],
    edges: const [
      RoadMapEdge(source: 'setup', target: 'clone'),
      RoadMapEdge(source: 'clone', target: 'pr'),
    ],
  );
}

void main() {
  group('RoadMap widget', () {
    testWidgets('renders current node title and content', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        child: RoadMap(controller: controller),
      ));

      expect(find.text('Set Up Environment'), findsWidgets);
      expect(find.text('Install required tools.'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('renders validation checklist', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        child: RoadMap(controller: controller),
      ));

      expect(find.text('IDE installed'), findsOneWidget);
      expect(find.text('SDK configured'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('renders status badge', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        child: RoadMap(controller: controller),
      ));

      expect(find.text('Ready'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('renders child navigation buttons', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        child: RoadMap(controller: controller),
      ));

      // Should show "Clone Repository" as a next navigation button.
      expect(find.widgetWithText(OutlinedButton, 'Clone Repository'),
          findsOneWidget);

      controller.dispose();
    });

    testWidgets('navigates to child on button tap', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        child: RoadMap(controller: controller),
      ));

      // Tap the "Clone Repository" nav button.
      await tester.tap(find.widgetWithText(OutlinedButton, 'Clone Repository'));
      await tester.pumpAndSettle();

      expect(controller.currentNodeId, 'clone');
      expect(find.text('Clone the main repo.'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('toggles validation checkbox', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        child: RoadMap(controller: controller),
      ));

      // Tap the first checkbox (IDE installed).
      final checkbox = find.byType(CheckboxListTile).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      expect(controller.currentNode.validationItems[0].isComplete, true);
      expect(controller.currentNode.validationItems[1].isComplete, false);

      controller.dispose();
    });

    testWidgets('readOnly disables checkboxes', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        child: RoadMap(controller: controller, readOnly: true),
      ));

      // Find a CheckboxListTile and verify it is disabled.
      final tile = tester.widget<CheckboxListTile>(
          find.byType(CheckboxListTile).first);
      expect(tile.onChanged, isNull);

      controller.dispose();
    });

    testWidgets('calls onValidationChange callback', (tester) async {
      final controller = RoadMapController(data: _sampleData());
      String? changedNodeId;
      String? changedItemId;
      bool? changedValue;

      await tester.pumpWidget(_app(
        child: RoadMap(
          controller: controller,
          onValidationChange: (nodeId, itemId, value) {
            changedNodeId = nodeId;
            changedItemId = itemId;
            changedValue = value;
          },
        ),
      ));

      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pumpAndSettle();

      expect(changedNodeId, 'setup');
      expect(changedItemId, 's1');
      expect(changedValue, true);

      controller.dispose();
    });

    testWidgets('nodePageBuilder replaces default page', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        child: RoadMap(
          controller: controller,
          nodePageBuilder: (context, node, ctrl) {
            return Center(child: Text('Custom: ${node.label}'));
          },
        ),
      ));

      expect(find.text('Custom: Set Up Environment'), findsOneWidget);
      // Default content should not appear.
      expect(find.text('Install required tools.'), findsNothing);

      controller.dispose();
    });

    testWidgets('back button appears after navigation', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        child: RoadMap(controller: controller),
      ));

      // No back button initially.
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // Navigate forward.
      await tester.tap(find.widgetWithText(OutlinedButton, 'Clone Repository'));
      await tester.pumpAndSettle();

      // Back button should appear.
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Tap back.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(controller.currentNodeId, 'setup');

      controller.dispose();
    });
  });

  group('Responsive layout', () {
    testWidgets('compact layout uses Scaffold with drawer', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        width: 400, // < 600
        child: RoadMap(controller: controller),
      ));

      // Should have a menu icon for the drawer.
      expect(find.byIcon(Icons.menu), findsOneWidget);

      controller.dispose();
    });

    testWidgets('expanded layout shows persistent sidebar', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        width: 900, // >= 600
        child: RoadMap(controller: controller),
      ));

      // Should have no menu icon (sidebar is persistent).
      expect(find.byIcon(Icons.menu), findsNothing);

      // Should show sidebar search field.
      expect(find.byType(TextField), findsOneWidget);

      controller.dispose();
    });
  });

  group('Sidebar', () {
    testWidgets('shows all root and child nodes', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        width: 900,
        child: RoadMap(controller: controller),
      ));

      // Root node should be visible in sidebar.
      // The title appears in both sidebar and page, so findsWidgets.
      expect(find.text('Set Up Environment'), findsWidgets);

      controller.dispose();
    });

    testWidgets('sidebar navigation updates page view', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        width: 900,
        child: RoadMap(controller: controller),
      ));

      // Navigate programmatically (simulating sidebar tap).
      controller.navigateTo('clone');
      await tester.pumpAndSettle();

      expect(controller.currentNodeId, 'clone');
      expect(find.text('Clone the main repo.'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('progress indicator shows percentage', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        width: 900,
        child: RoadMap(controller: controller),
      ));

      expect(find.text('0%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      controller.dispose();
    });
  });

  group('Style', () {
    testWidgets('applies custom style', (tester) async {
      final controller = RoadMapController(data: _sampleData());

      await tester.pumpWidget(_app(
        child: RoadMap(
          controller: controller,
          style: const RoadMapStyle(
            readyColor: Colors.orange,
            pagePadding: EdgeInsets.all(32),
          ),
        ),
      ));

      // Widget should render without errors.
      expect(find.byType(RoadMap), findsOneWidget);

      controller.dispose();
    });
  });
}
