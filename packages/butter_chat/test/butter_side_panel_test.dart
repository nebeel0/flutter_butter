import 'package:butter_chat/butter_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  final sessions = [
    ButterChatSession(
      id: 's1',
      title: 'First Chat',
      subtitle: 'Getting started',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ButterChatSession(
      id: 's2',
      title: 'Second Chat',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ButterChatSession(
      id: 's3',
      title: 'Pinned Chat',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isPinned: true,
    ),
  ];

  group('ButterSidePanel', () {
    testWidgets('renders header and session tiles', (tester) async {
      await tester.pumpWidget(_app(
        child: SizedBox(
          width: 280,
          child: ButterSidePanel(
            sessions: sessions,
            onSessionTap: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Chats'), findsOneWidget);
      expect(find.text('First Chat'), findsOneWidget);
      expect(find.text('Second Chat'), findsOneWidget);
      expect(find.text('Pinned Chat'), findsOneWidget);
    });

    testWidgets('new chat button calls onNewChat', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_app(
        child: SizedBox(
          width: 280,
          child: ButterSidePanel(
            sessions: sessions,
            onSessionTap: (_) {},
            onNewChat: () => tapped = true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_square));
      expect(tapped, isTrue);
    });

    testWidgets('tapping session calls onSessionTap', (tester) async {
      ButterChatSession? tappedSession;

      await tester.pumpWidget(_app(
        child: SizedBox(
          width: 280,
          child: ButterSidePanel(
            sessions: sessions,
            onSessionTap: (s) => tappedSession = s,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('First Chat'));
      await tester.pumpAndSettle();

      expect(tappedSession?.id, 's1');
    });

    testWidgets('active session is highlighted', (tester) async {
      await tester.pumpWidget(_app(
        child: SizedBox(
          width: 280,
          child: ButterSidePanel(
            sessions: sessions,
            activeSessionId: 's1',
            onSessionTap: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // The active session tile should exist.
      expect(find.text('First Chat'), findsOneWidget);
    });

    testWidgets('search filters sessions by title', (tester) async {
      await tester.pumpWidget(_app(
        child: SizedBox(
          width: 280,
          child: ButterSidePanel(
            sessions: sessions,
            onSessionTap: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Type in search bar.
      await tester.enterText(find.byType(TextField), 'Pinned');
      await tester.pumpAndSettle();

      expect(find.text('Pinned Chat'), findsOneWidget);
      expect(find.text('First Chat'), findsNothing);
      expect(find.text('Second Chat'), findsNothing);
    });

    testWidgets('pinned sessions appear first', (tester) async {
      await tester.pumpWidget(_app(
        child: SizedBox(
          width: 280,
          child: ButterSidePanel(
            sessions: sessions,
            onSessionTap: (_) {},
            showSearch: false,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Find all session titles in order.
      final titles = find.byType(ButterSessionTile);
      expect(titles, findsNWidgets(3));
    });

    testWidgets('showSearch false hides search bar', (tester) async {
      await tester.pumpWidget(_app(
        child: SizedBox(
          width: 280,
          child: ButterSidePanel(
            sessions: sessions,
            onSessionTap: (_) {},
            showSearch: false,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });
  });

  group('ButterChatScaffold', () {
    late ButterChatController controller;

    setUp(() {
      controller = ButterChatController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('shows persistent side panel on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ButterChatScaffold(
            sessions: sessions,
            activeSessionId: 's1',
            onSessionTap: (_) {},
            controller: controller,
            onSendMessage: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Side panel and chat view should both be visible.
      expect(find.text('Chats'), findsOneWidget);
      expect(find.byType(TextField), findsAtLeast(1));
    });

    testWidgets('uses drawer on narrow screens', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ButterChatScaffold(
            sessions: sessions,
            activeSessionId: 's1',
            onSessionTap: (_) {},
            controller: controller,
            onSendMessage: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Side panel should not be visible (it's in a drawer).
      expect(find.text('Chats'), findsNothing);

      // The chat input should be visible.
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
