import 'package:butter_chat/butter_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('ButterChatView', () {
    late ButterChatController controller;

    setUp(() {
      controller = ButterChatController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('shows welcome placeholder when empty', (tester) async {
      await tester.pumpWidget(_app(
        child: ButterChatView(
          controller: controller,
          onSendMessage: (_) {},
        ),
      ));

      expect(find.text('How can I help you today?'), findsOneWidget);
    });

    testWidgets('shows custom welcome via welcomeBuilder', (tester) async {
      await tester.pumpWidget(_app(
        child: ButterChatView(
          controller: controller,
          onSendMessage: (_) {},
          welcomeBuilder: (context) => const Text('Custom welcome'),
        ),
      ));

      expect(find.text('Custom welcome'), findsOneWidget);
    });

    testWidgets('shows messages after adding them', (tester) async {
      controller.addUserMessage(id: '1', content: 'Hello');

      await tester.pumpWidget(_app(
        child: ButterChatView(
          controller: controller,
          onSendMessage: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // The welcome placeholder should be gone.
      expect(find.text('How can I help you today?'), findsNothing);
    });

    testWidgets('input field is present', (tester) async {
      await tester.pumpWidget(_app(
        child: ButterChatView(
          controller: controller,
          onSendMessage: (_) {},
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('onSendMessage fires when sending text', (tester) async {
      String? sentText;

      await tester.pumpWidget(_app(
        child: ButterChatView(
          controller: controller,
          onSendMessage: (text) => sentText = text,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();

      // Tap the send button.
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      expect(sentText, 'Hello');
    });

    testWidgets('shows stop button when streaming', (tester) async {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');
      controller.setMessageStatus('2', ButterChatMessageStatus.streaming);

      await tester.pumpWidget(_app(
        child: ButterChatView(
          controller: controller,
          onSendMessage: (_) {},
          onStopGeneration: () {},
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.stop), findsOneWidget);
    });

    testWidgets('shows status bar when statusLabel is set', (tester) async {
      controller.setStatusLabel('Searching...');

      await tester.pumpWidget(_app(
        child: ButterChatView(
          controller: controller,
          onSendMessage: (_) {},
        ),
      ));
      await tester.pump();

      expect(find.text('Searching...'), findsOneWidget);
    });

    testWidgets('shows suggestion cards on welcome screen', (tester) async {
      const suggestions = [
        ButterSuggestion(
          title: 'Tell me about Flutter',
          subtitle: 'UI framework',
          prompt: 'Tell me about Flutter',
        ),
        ButterSuggestion(
          title: 'Write code',
          prompt: 'Write some Dart code',
        ),
      ];

      await tester.pumpWidget(_app(
        child: ButterChatView(
          controller: controller,
          onSendMessage: (_) {},
          suggestions: suggestions,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tell me about Flutter'), findsOneWidget);
      expect(find.text('Write code'), findsOneWidget);
      expect(find.text('UI framework'), findsOneWidget);
    });

    testWidgets('tapping suggestion sends prompt', (tester) async {
      String? sentText;
      const suggestions = [
        ButterSuggestion(
          title: 'Hello',
          prompt: 'Say hello!',
        ),
      ];

      await tester.pumpWidget(_app(
        child: ButterChatView(
          controller: controller,
          onSendMessage: (text) => sentText = text,
          suggestions: suggestions,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hello'));
      await tester.pumpAndSettle();

      expect(sentText, 'Say hello!');
    });

    testWidgets('messageHeaderBuilder is rendered for assistant messages',
        (tester) async {
      controller.addUserMessage(id: '1', content: 'Hi');
      controller.addAssistantMessage(id: '2', parentId: '1');
      controller.appendContent('2', 'Hello!');
      controller.setMessageStatus('2', ButterChatMessageStatus.complete);

      await tester.pumpWidget(_app(
        child: ButterChatView(
          controller: controller,
          onSendMessage: (_) {},
          messageHeaderBuilder: (context, message) {
            return const Text('GPT-4o');
          },
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('GPT-4o'), findsOneWidget);
    });

    testWidgets('avatarBuilder renders avatar next to assistant messages',
        (tester) async {
      controller.addUserMessage(id: '1', content: 'Hi');
      controller.addAssistantMessage(id: '2', parentId: '1');
      controller.appendContent('2', 'Hello!');
      controller.setMessageStatus('2', ButterChatMessageStatus.complete);

      await tester.pumpWidget(_app(
        child: ButterChatView(
          controller: controller,
          onSendMessage: (_) {},
          style: ButterChatStyle(
            messageStyle: ButterMessageStyle(
              avatarBuilder: (context, isUser) {
                return const Icon(Icons.smart_toy, key: Key('avatar'));
              },
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('avatar')), findsOneWidget);
    });

    testWidgets('maxContentWidth defaults to 1024', (tester) async {
      const style = ButterChatStyle();
      expect(style.maxContentWidth, 1024.0);
    });
  });
}
