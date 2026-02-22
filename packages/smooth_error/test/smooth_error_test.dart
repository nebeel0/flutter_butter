import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_error/smooth_error.dart';

void main() {
  group('SmoothErrorScreen', () {
    testWidgets('renders title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothErrorScreen(
              title: 'Test Error',
              subtitle: 'Something broke',
            ),
          ),
        ),
      );

      expect(find.text('Test Error'), findsOneWidget);
      expect(find.text('Something broke'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided',
        (WidgetTester tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothErrorScreen(
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(retried, isTrue);
    });

    testWidgets('hides retry button when onRetry is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothErrorScreen(),
          ),
        ),
      );

      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('.network() factory has correct defaults',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SmoothErrorScreen.network()),
        ),
      );

      expect(find.text('Unable to connect'), findsOneWidget);
    });

    testWidgets('.unexpected() factory has correct defaults',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SmoothErrorScreen.unexpected()),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('.notFound() factory has correct defaults',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SmoothErrorScreen.notFound()),
        ),
      );

      expect(find.text('Not found'), findsOneWidget);
    });

    testWidgets('.empty() factory has correct defaults',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SmoothErrorScreen.empty()),
        ),
      );

      expect(find.text('Nothing here yet'), findsOneWidget);
    });
  });

  group('SmoothErrorCard', () {
    testWidgets('renders in full mode by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothErrorCard(
              title: 'Card Error',
              subtitle: 'Details here',
            ),
          ),
        ),
      );

      expect(find.text('Card Error'), findsOneWidget);
      expect(find.text('Details here'), findsOneWidget);
    });

    testWidgets('renders in compact mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothErrorCard(
              title: 'Compact Error',
              compact: true,
            ),
          ),
        ),
      );

      expect(find.text('Compact Error'), findsOneWidget);
    });

    testWidgets('compact mode shows retry icon when provided',
        (WidgetTester tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothErrorCard(
              title: 'Error',
              compact: true,
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      expect(retried, isTrue);
    });

    testWidgets('.network() factory has correct defaults',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothErrorCard.network(),
          ),
        ),
      );

      expect(find.text('Connection error'), findsOneWidget);
    });

    testWidgets('.notFound() factory has correct defaults',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothErrorCard.notFound(),
          ),
        ),
      );

      expect(find.text('Not found'), findsOneWidget);
    });

    testWidgets('.unexpected() factory has correct defaults',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothErrorCard.unexpected(),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('.empty() factory has correct defaults',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothErrorCard.empty(),
          ),
        ),
      );

      expect(find.text('Nothing here yet'), findsOneWidget);
    });
  });
}
