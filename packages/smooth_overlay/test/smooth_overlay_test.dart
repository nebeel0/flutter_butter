import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_overlay/smooth_overlay.dart';

void main() {
  testWidgets('renders child and close button', (WidgetTester tester) async {
    var closed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothOverlayCard(
              onClose: () => closed = true,
              child: const SizedBox(
                width: 200,
                height: 150,
                child: Center(child: Text('Content')),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Content'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
  });

  testWidgets('shows hint text when provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothOverlayCard(
              onClose: () {},
              hintText: 'Click to expand',
              hintIcon: Icons.open_in_full,
              child: const SizedBox(width: 200, height: 100),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Click to expand'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_full), findsOneWidget);
  });

  testWidgets('calls onTap when card body is tapped',
      (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothOverlayCard(
              onClose: () {},
              onTap: () => tapped = true,
              child: const SizedBox(
                width: 200,
                height: 150,
                child: Center(child: Text('Tap me')),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('renders action widgets', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothOverlayCard(
              onClose: () {},
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
              child: const SizedBox(width: 200, height: 100),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.share), findsOneWidget);
  });

  testWidgets('uses custom background color', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmoothOverlayCard(
              onClose: () {},
              backgroundColor: Colors.grey.shade100,
              child: const SizedBox(width: 200, height: 100),
            ),
          ),
        ),
      ),
    );

    // Find the outer Container (first one with BoxDecoration)
    final containers = tester.widgetList<Container>(find.byType(Container));
    final outerContainer = containers.firstWhere(
      (c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).boxShadow != null,
    );
    final decoration = outerContainer.decoration! as BoxDecoration;
    expect(decoration.color, Colors.grey.shade100);
  });
}
