import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_button/smooth_button.dart';

void main() {
  testWidgets('SmoothButton renders child and responds to tap',
      (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothButton(
              onPressed: () => tapped = true,
              child: const Text('Tap me'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tap me'), findsOneWidget);

    await tester.tap(find.text('Tap me'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('SmoothButton uses custom color', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothButton(
              onPressed: () {},
              color: Colors.red,
              child: const Text('Red'),
            ),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, Colors.red);
  });
}
