import 'package:flutter_test/flutter_test.dart';

import 'package:butter_chat_example/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ButterChatExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('ButterChat Demo'), findsOneWidget);
  });
}
