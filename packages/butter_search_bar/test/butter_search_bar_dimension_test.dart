import 'package:butter_search_bar/butter_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
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
            ListTile(
              title: const Text('London'),
              onTap: () => onChanged('London'),
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
    ButterSearchDimension<String>(
      key: 'who',
      label: 'Who',
      emptyDisplayValue: 'Add guests',
      builder: (context, value, onChanged) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('2 guests'),
              onTap: () => onChanged('2 guests'),
            ),
          ],
        );
      },
    ),
  ];
}

void main() {
  group('Controller dimension state', () {
    late ButterSearchBarController controller;

    setUp(() {
      controller = ButterSearchBarController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('hasDimensions is false initially', () {
      expect(controller.hasDimensions, isFalse);
      expect(controller.dimensions, isEmpty);
    });

    test('setDimensions populates dimensions', () {
      final dims = _testDimensions();
      controller.setDimensions(dims);
      expect(controller.hasDimensions, isTrue);
      expect(controller.dimensions.length, 3);
      expect(controller.dimensions[0].key, 'where');
      expect(controller.dimensions[1].key, 'when');
      expect(controller.dimensions[2].key, 'who');
    });

    test('setDimensions clears active dimension index', () {
      final dims = _testDimensions();
      controller.setDimensions(dims);
      controller.setActiveDimension(1);
      expect(controller.activeDimensionIndex, 1);
      controller.setDimensions(dims);
      expect(controller.activeDimensionIndex, isNull);
    });

    test('updateDimension changes value and displayValue', () {
      controller.setDimensions(_testDimensions());
      controller.updateDimension('where', 'Paris', 'Paris');
      expect(controller.dimensions[0].value, 'Paris');
      expect(controller.dimensions[0].displayValue, 'Paris');
    });

    test('updateDimension ignores unknown key', () {
      controller.setDimensions(_testDimensions());
      var notified = false;
      controller.addListener(() => notified = true);
      controller.updateDimension('nonexistent', 'value', 'display');
      expect(notified, isFalse);
    });

    test('activeDimensionIndex starts null', () {
      controller.setDimensions(_testDimensions());
      expect(controller.activeDimensionIndex, isNull);
    });

    test('setActiveDimension updates index', () {
      controller.setDimensions(_testDimensions());
      controller.setActiveDimension(2);
      expect(controller.activeDimensionIndex, 2);
    });

    test('setActiveDimension does not notify for same value', () {
      controller.setDimensions(_testDimensions());
      controller.setActiveDimension(1);
      var notified = false;
      controller.addListener(() => notified = true);
      controller.setActiveDimension(1);
      expect(notified, isFalse);
    });

    test('advanceToNextDimension goes to next unfilled', () {
      controller.setDimensions(_testDimensions());
      controller.setActiveDimension(0);
      controller.updateDimension('where', 'Paris', 'Paris');
      controller.advanceToNextDimension();
      expect(controller.activeDimensionIndex, 1);
    });

    test('advanceToNextDimension sets null when all filled', () {
      controller.setDimensions(_testDimensions());
      controller.updateDimension('where', 'Paris', 'Paris');
      controller.updateDimension('when', 'Weekend', 'Weekend');
      controller.updateDimension('who', '2', '2');
      controller.setActiveDimension(2);
      controller.advanceToNextDimension();
      expect(controller.activeDimensionIndex, isNull);
    });

    test('advanceToNextDimension no-ops with empty dimensions', () {
      controller.advanceToNextDimension();
      expect(controller.activeDimensionIndex, isNull);
    });

    test('dimensionSummary uses displayValue then emptyDisplayValue', () {
      controller.setDimensions(_testDimensions());
      expect(controller.dimensionSummary, 'Anywhere · Any week · Add guests');
      controller.updateDimension('where', 'Paris', 'Paris');
      expect(controller.dimensionSummary, 'Paris · Any week · Add guests');
    });

    test('allDimensionsFilled is false when not all have values', () {
      controller.setDimensions(_testDimensions());
      expect(controller.allDimensionsFilled, isFalse);
      controller.updateDimension('where', 'Paris', 'Paris');
      expect(controller.allDimensionsFilled, isFalse);
    });

    test('allDimensionsFilled is true when all have values', () {
      controller.setDimensions(_testDimensions());
      controller.updateDimension('where', 'Paris', 'Paris');
      controller.updateDimension('when', 'Weekend', 'Weekend');
      controller.updateDimension('who', '2', '2');
      expect(controller.allDimensionsFilled, isTrue);
    });

    test('clearDimensions resets all values to null', () {
      controller.setDimensions(_testDimensions());
      controller.updateDimension('where', 'Paris', 'Paris');
      controller.updateDimension('when', 'Weekend', 'Weekend');
      controller.setActiveDimension(1);
      controller.clearDimensions();
      expect(controller.dimensions[0].value, isNull);
      expect(controller.dimensions[1].value, isNull);
      expect(controller.activeDimensionIndex, isNull);
    });
  });

  group('Widget with dimensions', () {
    testWidgets('renders dimension chips when dimensions provided',
        (tester) async {
      await tester.pumpWidget(_app(
        child: ButterSearchBar(
          dimensions: _testDimensions(),
          platformMode: ButterPlatformMode.desktop,
          constraints: const BoxConstraints(maxWidth: 500),
        ),
      ));

      expect(find.text('Where'), findsOneWidget);
      expect(find.text('When'), findsOneWidget);
      expect(find.text('Who'), findsOneWidget);
      expect(find.text('Anywhere'), findsOneWidget);
      expect(find.text('Any week'), findsOneWidget);
      expect(find.text('Add guests'), findsOneWidget);
    });

    testWidgets('no TextField when dimensions are provided', (tester) async {
      await tester.pumpWidget(_app(
        child: ButterSearchBar(
          dimensions: _testDimensions(),
          platformMode: ButterPlatformMode.desktop,
          constraints: const BoxConstraints(maxWidth: 500),
        ),
      ));

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('tapping chip activates dimension via controller',
        (tester) async {
      final controller = ButterSearchBarController();
      await tester.pumpWidget(_app(
        child: ButterSearchBar(
          controller: controller,
          dimensions: _testDimensions(),
          platformMode: ButterPlatformMode.desktop,
          constraints: const BoxConstraints(maxWidth: 500),
        ),
      ));

      // Use controller directly to activate a dimension
      controller.setActiveDimension(1);
      await tester.pumpAndSettle();
      expect(controller.activeDimensionIndex, 1);

      controller.dispose();
    });

    testWidgets('dimension builder appears in overlay when chip tapped',
        (tester) async {
      await tester.pumpWidget(_app(
        child: ButterSearchBar(
          dimensions: _testDimensions(),
          platformMode: ButterPlatformMode.desktop,
          constraints: const BoxConstraints(maxWidth: 500),
        ),
      ));

      // Tap the "Where" label to activate that dimension
      await tester.tap(find.text('Anywhere'));
      await tester.pumpAndSettle();

      // The dimension builder should show Paris and London in the overlay
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('London'), findsOneWidget);
    });

    testWidgets('onDimensionChanged fires when value committed',
        (tester) async {
      String? changedKey;
      dynamic changedValue;

      await tester.pumpWidget(_app(
        child: ButterSearchBar(
          dimensions: _testDimensions(),
          platformMode: ButterPlatformMode.desktop,
          constraints: const BoxConstraints(maxWidth: 500),
          onDimensionChanged: (key, value) {
            changedKey = key;
            changedValue = value;
          },
        ),
      ));

      // Tap first dimension chip to open its picker
      await tester.tap(find.text('Anywhere'));
      await tester.pumpAndSettle();

      // Tap Paris in the picker
      await tester.tap(find.text('Paris'));
      await tester.pumpAndSettle();

      expect(changedKey, 'where');
      expect(changedValue, 'Paris');
    });

    testWidgets('without dimensions, works as normal text search bar',
        (tester) async {
      await tester.pumpWidget(_app(
        child: const ButterSearchBar(
          hintText: 'Search...',
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);
    });

    testWidgets('dimensions via controller also works', (tester) async {
      final controller = ButterSearchBarController();
      controller.setDimensions(_testDimensions());

      await tester.pumpWidget(_app(
        child: ButterSearchBar(
          controller: controller,
          platformMode: ButterPlatformMode.desktop,
          constraints: const BoxConstraints(maxWidth: 500),
        ),
      ));

      expect(find.text('Where'), findsOneWidget);
      expect(find.text('Anywhere'), findsOneWidget);
      controller.dispose();
    });
  });
}
