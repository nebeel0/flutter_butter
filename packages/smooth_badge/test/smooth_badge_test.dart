import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_badge/smooth_badge.dart';

void main() {
  testWidgets('renders text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothBadge(text: 'Active', color: Colors.green),
          ),
        ),
      ),
    );

    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('renders label below text when provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothBadge(
              text: 'A+',
              label: 'Rating',
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );

    expect(find.text('A+'), findsOneWidget);
    expect(find.text('Rating'), findsOneWidget);
  });

  testWidgets('uses custom background color', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothBadge(text: 'Test', color: Colors.purple),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).last);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, Colors.purple);
  });

  testWidgets('auto-selects white text on dark background',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothBadge(text: 'Dark', color: Colors.black),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Dark'));
    expect((text.style as TextStyle).color, Colors.white);
  });

  testWidgets('auto-selects dark text on light background',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothBadge(text: 'Light', color: Colors.yellow),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Light'));
    expect((text.style as TextStyle).color, Colors.black87);
  });

  testWidgets('.status() factory uses correct color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothBadge.status(
              text: 'Error',
              status: SmoothBadgeStatus.error,
            ),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).last);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, Colors.red);
  });
}
