import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_toast/smooth_toast.dart';

void main() {
  tearDown(() {
    SmoothToast.reset();
  });

  testWidgets('success toast shows title and message',
      (WidgetTester tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    SmoothToast.setNavigatorKey(navigatorKey);
    SmoothToast.success('Item saved', title: 'Done');

    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Item saved'), findsOneWidget);

    SmoothToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('error toast shows with default title',
      (WidgetTester tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    SmoothToast.setNavigatorKey(navigatorKey);
    SmoothToast.error('Something failed');

    await tester.pumpAndSettle();

    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Something failed'), findsOneWidget);

    SmoothToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('info toast shows with default title',
      (WidgetTester tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    SmoothToast.setNavigatorKey(navigatorKey);
    SmoothToast.info('FYI this happened');

    await tester.pumpAndSettle();

    expect(find.text('Info'), findsOneWidget);
    expect(find.text('FYI this happened'), findsOneWidget);

    SmoothToast.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('dismiss button removes toast', (WidgetTester tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    SmoothToast.setNavigatorKey(navigatorKey);
    SmoothToast.info('Dismissable');

    await tester.pumpAndSettle();

    expect(find.text('Dismissable'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Dismissable'), findsNothing);
  });

  testWidgets('dismissAll removes all toasts', (WidgetTester tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    SmoothToast.setNavigatorKey(navigatorKey);
    SmoothToast.info('Toast 1');
    SmoothToast.info('Toast 2');

    await tester.pumpAndSettle();

    expect(find.text('Toast 1'), findsOneWidget);
    expect(find.text('Toast 2'), findsOneWidget);

    SmoothToast.dismissAll();
    await tester.pumpAndSettle();

    expect(find.text('Toast 1'), findsNothing);
    expect(find.text('Toast 2'), findsNothing);
  });
}
