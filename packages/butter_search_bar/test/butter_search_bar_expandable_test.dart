import 'package:butter_search_bar/butter_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('renders collapsed initially with search icon', (tester) async {
    await tester.pumpWidget(_app(
      child: const ButterSearchBar.expandable(),
    ));

    expect(find.byIcon(Icons.search), findsOneWidget);
    // No text field visible when collapsed
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('expands on tap and shows text field', (tester) async {
    await tester.pumpWidget(_app(
      child: const ButterSearchBar.expandable(),
    ));

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('controller expand/collapse works', (tester) async {
    final controller = ButterSearchBarController();
    await tester.pumpWidget(_app(
      child: ButterSearchBar.expandable(controller: controller),
    ));

    expect(find.byType(TextField), findsNothing);

    controller.expand();
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    controller.collapse();
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    controller.dispose();
  });

  testWidgets('controller toggle works', (tester) async {
    final controller = ButterSearchBarController();
    await tester.pumpWidget(_app(
      child: ButterSearchBar.expandable(controller: controller),
    ));

    controller.toggle();
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    controller.toggle();
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    controller.dispose();
  });

  testWidgets('custom collapsed icon', (tester) async {
    await tester.pumpWidget(_app(
      child: const ButterSearchBar.expandable(
        collapsedIcon: Icon(Icons.filter_list),
      ),
    ));

    expect(find.byIcon(Icons.filter_list), findsOneWidget);
  });

  testWidgets('expand direction defaults to right', (tester) async {
    const bar = ButterSearchBar.expandable();
    expect(bar.expandDirection, ExpandDirection.right);
  });

  testWidgets('custom animation duration is accepted', (tester) async {
    await tester.pumpWidget(_app(
      child: const ButterSearchBar.expandable(
        animationDuration: Duration(milliseconds: 100),
      ),
    ));

    // Tap to expand with fast animation
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
  });
}
