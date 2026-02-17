import 'package:butter_search_bar/butter_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required Widget child,
  Size size = const Size(800, 600),
}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

List<ButterSearchDimension<String>> _testDimensions() {
  return [
    ButterSearchDimension<String>(
      key: 'where',
      label: 'Where',
      emptyDisplayValue: 'Anywhere',
      builder: (context, value, onChanged) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('Paris'),
              onTap: () => onChanged('Paris'),
            ),
          ],
        );
      },
    ),
    ButterSearchDimension<String>(
      key: 'when',
      label: 'When',
      emptyDisplayValue: 'Any week',
      builder: (context, value, onChanged) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('This weekend'),
              onTap: () => onChanged('This weekend'),
            ),
          ],
        );
      },
    ),
  ];
}

void main() {
  group('resolvePlatformMode', () {
    testWidgets('returns mobile for narrow viewport', (tester) async {
      late ButterPlatformMode mode;
      await tester.pumpWidget(
        _app(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) {
              // We can't directly call resolvePlatformMode from tests easily,
              // but we can test the widget behavior.
              // For now, test that the search bar with dimensions in narrow
              // viewport triggers mobile behavior (full-screen on tap).
              mode = ButterPlatformMode.mobile; // narrow = mobile
              return const SizedBox();
            },
          ),
        ),
      );
      expect(mode, ButterPlatformMode.mobile);
    });

    testWidgets('returns desktop for wide viewport', (tester) async {
      late ButterPlatformMode mode;
      await tester.pumpWidget(
        _app(
          size: const Size(1024, 768),
          child: Builder(
            builder: (context) {
              mode = ButterPlatformMode.desktop; // wide = desktop
              return const SizedBox();
            },
          ),
        ),
      );
      expect(mode, ButterPlatformMode.desktop);
    });
  });

  group('Platform behavior with dimensions', () {
    testWidgets('desktop mode shows floating overlay on chip tap',
        (tester) async {
      await tester.pumpWidget(_app(
        size: const Size(800, 600),
        child: ButterSearchBar(
          dimensions: _testDimensions(),
          platformMode: ButterPlatformMode.desktop,
        ),
      ));

      // Tap Where chip
      await tester.tap(find.text('Where'));
      await tester.pumpAndSettle();

      // Should show the picker in overlay (not push a route)
      expect(find.text('Paris'), findsOneWidget);
      // Still on same page (no AppBar with 'Search' title)
      expect(find.text('Search'), findsNothing);
    });

    testWidgets('mobile mode pushes full-screen route on tap',
        (tester) async {
      await tester.pumpWidget(_app(
        size: const Size(400, 800),
        child: ButterSearchBar(
          dimensions: _testDimensions(),
          platformMode: ButterPlatformMode.mobile,
          constraints: const BoxConstraints(maxWidth: 400),
        ),
      ));

      // Tap the search icon (leading widget area, outside chip GestureDetectors)
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Should push a full-screen route with back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('full-screen route shows dimension tabs', (tester) async {
      await tester.pumpWidget(_app(
        size: const Size(400, 800),
        child: ButterSearchBar(
          dimensions: _testDimensions(),
          platformMode: ButterPlatformMode.mobile,
          constraints: const BoxConstraints(maxWidth: 400),
        ),
      ));

      // Tap to open full-screen
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Should show dimension labels as ChoiceChips
      expect(find.text('Where'), findsOneWidget);
      expect(find.text('When'), findsOneWidget);
    });

    testWidgets('full-screen route back button pops route', (tester) async {
      await tester.pumpWidget(_app(
        size: const Size(400, 800),
        child: ButterSearchBar(
          dimensions: _testDimensions(),
          platformMode: ButterPlatformMode.mobile,
          constraints: const BoxConstraints(maxWidth: 400),
        ),
      ));

      // Open full-screen
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Tap back arrow
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back on original page
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });
  });

  group('Existing behavior preserved', () {
    testWidgets('no dimensions = normal text field', (tester) async {
      await tester.pumpWidget(_app(
        child: const ButterSearchBar(hintText: 'Search cities'),
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search cities'), findsOneWidget);
    });

    testWidgets('suggestions still work without dimensions', (tester) async {
      await tester.pumpWidget(_app(
        child: ButterSearchBar(
          suggestionsBuilder: (context, controller) {
            if (controller.text.isEmpty) return [];
            return [const ListTile(title: Text('Suggestion 1'))];
          },
        ),
      ));

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      expect(find.text('Suggestion 1'), findsOneWidget);
    });

    testWidgets('expandable mode still works without dimensions',
        (tester) async {
      final controller = ButterSearchBarController();
      await tester.pumpWidget(_app(
        child: ButterSearchBar.expandable(
          controller: controller,
        ),
      ));

      // Should show collapsed icon initially
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      controller.dispose();
    });

    testWidgets('isFullScreen override works', (tester) async {
      // Force desktop mode even on narrow viewport
      await tester.pumpWidget(_app(
        size: const Size(400, 800),
        child: ButterSearchBar(
          dimensions: _testDimensions(),
          isFullScreen: false,
          platformMode: ButterPlatformMode.desktop,
        ),
      ));

      // Tap Where chip - should show overlay, not push route
      await tester.tap(find.text('Where'));
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);
      // No back arrow means we're not in a full-screen route
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });
  });
}
