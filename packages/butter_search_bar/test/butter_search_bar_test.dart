import 'package:butter_search_bar/butter_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('renders hint text', (tester) async {
    await tester.pumpWidget(_app(
      child: const ButterSearchBar(hintText: 'Search fruits'),
    ));

    expect(find.text('Search fruits'), findsOneWidget);
  });

  testWidgets('onChanged fires when text changes', (tester) async {
    String? changed;
    await tester.pumpWidget(_app(
      child: ButterSearchBar(onChanged: (v) => changed = v),
    ));

    await tester.enterText(find.byType(TextField), 'apple');
    expect(changed, 'apple');
  });

  testWidgets('onSubmitted fires', (tester) async {
    String? submitted;
    await tester.pumpWidget(_app(
      child: ButterSearchBar(onSubmitted: (v) => submitted = v),
    ));

    await tester.enterText(find.byType(TextField), 'banana');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    expect(submitted, 'banana');
  });

  testWidgets('clear button shows when text is entered and clears text',
      (tester) async {
    final controller = ButterSearchBarController();
    await tester.pumpWidget(_app(
      child: ButterSearchBar(controller: controller),
    ));

    // Initially no close icon visible (scale is 0)
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pumpAndSettle();

    // Clear button should now be visible
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(controller.text, '');
    controller.dispose();
  });

  testWidgets('custom style applies border radius', (tester) async {
    await tester.pumpWidget(_app(
      child: ButterSearchBar(
        style: ButterSearchBarStyle(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ));

    await tester.pump();
    // Widget renders without error
    expect(find.byType(ButterSearchBar), findsOneWidget);
  });

  testWidgets('onFocusChanged fires', (tester) async {
    bool? focused;
    await tester.pumpWidget(_app(
      child: ButterSearchBar(onFocusChanged: (v) => focused = v),
    ));

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(focused, isTrue);
  });

  testWidgets('disabled state prevents interaction', (tester) async {
    var changed = false;
    await tester.pumpWidget(_app(
      child: ButterSearchBar(
        enabled: false,
        onChanged: (_) => changed = true,
      ),
    ));

    // TextField should be disabled
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);
    expect(changed, isFalse);
  });

  testWidgets('custom leading and trailing widgets', (tester) async {
    await tester.pumpWidget(_app(
      child: ButterSearchBar(
        leading: const Icon(Icons.mic, key: Key('leading')),
        trailing: const [
          Icon(Icons.tune, key: Key('trailing1')),
          Icon(Icons.more_vert, key: Key('trailing2')),
        ],
      ),
    ));

    expect(find.byKey(const Key('leading')), findsOneWidget);
    expect(find.byKey(const Key('trailing1')), findsOneWidget);
    expect(find.byKey(const Key('trailing2')), findsOneWidget);
  });

  testWidgets('renders without error with default style', (tester) async {
    await tester.pumpWidget(_app(
      child: const ButterSearchBar(),
    ));

    expect(find.byType(ButterSearchBar), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('external focusNode controls focus', (tester) async {
    final focusNode = FocusNode();
    bool? focused;
    await tester.pumpWidget(_app(
      child: ButterSearchBar(
        focusNode: focusNode,
        onFocusChanged: (v) => focused = v,
      ),
    ));

    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(focused, isTrue);

    focusNode.unfocus();
    await tester.pumpAndSettle();
    expect(focused, isFalse);

    focusNode.dispose();
  });

  testWidgets('readOnly prevents text editing', (tester) async {
    await tester.pumpWidget(_app(
      child: const ButterSearchBar(readOnly: true),
    ));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.readOnly, isTrue);
  });

  testWidgets('keyboardType is passed through', (tester) async {
    await tester.pumpWidget(_app(
      child: const ButterSearchBar(keyboardType: TextInputType.number),
    ));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.keyboardType, TextInputType.number);
  });

  testWidgets('scrollPadding is passed through', (tester) async {
    await tester.pumpWidget(_app(
      child: const ButterSearchBar(
        scrollPadding: EdgeInsets.all(40.0),
      ),
    ));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.scrollPadding, const EdgeInsets.all(40.0));
  });

  testWidgets('smartDashesType and smartQuotesType are passed through',
      (tester) async {
    await tester.pumpWidget(_app(
      child: const ButterSearchBar(
        smartDashesType: SmartDashesType.disabled,
        smartQuotesType: SmartQuotesType.disabled,
      ),
    ));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.smartDashesType, SmartDashesType.disabled);
    expect(textField.smartQuotesType, SmartQuotesType.disabled);
  });

  testWidgets('custom shape style overrides borderRadius', (tester) async {
    await tester.pumpWidget(_app(
      child: ButterSearchBar(
        style: ButterSearchBarStyle(
          shape: WidgetStateProperty.all(
            const StadiumBorder(),
          ),
        ),
      ),
    ));

    // Renders without error with custom shape
    expect(find.byType(ButterSearchBar), findsOneWidget);
  });

  testWidgets('overlayColor style is applied to InkWell', (tester) async {
    await tester.pumpWidget(_app(
      child: ButterSearchBar(
        style: ButterSearchBarStyle(
          overlayColor: WidgetStateProperty.all(Colors.red.withAlpha(25)),
        ),
      ),
    ));

    final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
    final hasOverlayColor = inkWells.any((iw) => iw.overlayColor != null);
    expect(hasOverlayColor, isTrue);
  });
}
