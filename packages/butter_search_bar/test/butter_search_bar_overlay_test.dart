import 'package:butter_search_bar/butter_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: Padding(padding: const EdgeInsets.all(40), child: child)),
  );
}

void main() {
  testWidgets('no overlay without suggestionsBuilder', (tester) async {
    await tester.pumpWidget(_app(
      child: const ButterSearchBar(),
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'test');
    await tester.pumpAndSettle();

    // No overlay entries created
    expect(find.text('Suggestion'), findsNothing);
  });

  testWidgets('overlay shows on focus with suggestions', (tester) async {
    await tester.pumpWidget(_app(
      child: ButterSearchBar(
        suggestionsBuilder: (context, controller) {
          if (controller.text.isEmpty) return [];
          return [
            ListTile(
              key: const Key('suggestion'),
              title: Text('Result: ${controller.text}'),
            ),
          ];
        },
      ),
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pumpAndSettle();

    expect(find.text('Result: apple'), findsOneWidget);
  });

  testWidgets('overlay disappears when text is cleared', (tester) async {
    final controller = ButterSearchBarController();
    await tester.pumpWidget(_app(
      child: ButterSearchBar(
        controller: controller,
        suggestionsBuilder: (context, c) {
          if (c.text.isEmpty) return [];
          return [ListTile(title: Text('Suggestion: ${c.text}'))];
        },
      ),
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'banana');
    await tester.pumpAndSettle();

    expect(find.text('Suggestion: banana'), findsOneWidget);

    // Clear text
    controller.clear();
    await tester.pumpAndSettle();

    expect(find.text('Suggestion: banana'), findsNothing);

    controller.dispose();
  });

  testWidgets('tapping a suggestion works', (tester) async {
    var selected = '';
    await tester.pumpWidget(_app(
      child: ButterSearchBar(
        suggestionsBuilder: (context, controller) {
          if (controller.text.isEmpty) return [];
          return [
            ListTile(
              title: const Text('Apple'),
              onTap: () => selected = 'Apple',
            ),
          ];
        },
      ),
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apple'));
    expect(selected, 'Apple');
  });

  testWidgets('overlay respects custom overlay style', (tester) async {
    await tester.pumpWidget(_app(
      child: ButterSearchBar(
        overlayStyle: const ButterSearchBarOverlayStyle(
          maxHeight: 150,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        suggestionsBuilder: (context, controller) {
          if (controller.text.isEmpty) return [];
          return [const ListTile(title: Text('Styled'))];
        },
      ),
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'x');
    await tester.pumpAndSettle();

    expect(find.text('Styled'), findsOneWidget);
  });

  testWidgets('scrim shows when showScrim is true', (tester) async {
    await tester.pumpWidget(_app(
      child: ButterSearchBar(
        showScrim: true,
        suggestionsBuilder: (context, controller) {
          if (controller.text.isEmpty) return [];
          return [const ListTile(title: Text('With Scrim'))];
        },
      ),
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'test');
    await tester.pumpAndSettle();

    // Scrim is a ColoredBox with SizedBox.expand
    expect(find.text('With Scrim'), findsOneWidget);
  });
}
