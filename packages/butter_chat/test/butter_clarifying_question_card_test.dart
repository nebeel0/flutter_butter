import 'package:butter_chat/butter_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('ButterClarifyingQuestionCard', () {
    testWidgets('renders unresolved question with options', (tester) async {
      const question = ButterClarifyingQuestion(
        questionText: 'What do you prefer?',
        options: [
          ButterQuestionOption(id: 'a', label: 'Alpha', description: 'First'),
          ButterQuestionOption(id: 'b', label: 'Beta'),
        ],
      );

      await tester.pumpWidget(_app(
        child: ButterClarifyingQuestionCard(
          question: question,
          onSubmit: (_, __) {},
        ),
      ));

      expect(find.text('What do you prefer?'), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('submit button is disabled when no selection', (tester) async {
      const question = ButterClarifyingQuestion(
        questionText: 'Pick one',
        options: [
          ButterQuestionOption(id: 'a', label: 'A'),
        ],
      );

      await tester.pumpWidget(_app(
        child: ButterClarifyingQuestionCard(
          question: question,
          onSubmit: (_, __) {},
        ),
      ));

      final button =
          tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('single select enables submit after tapping option',
        (tester) async {
      List<String>? submittedIds;
      String? submittedOther;

      const question = ButterClarifyingQuestion(
        questionText: 'Pick one',
        options: [
          ButterQuestionOption(id: 'a', label: 'A'),
          ButterQuestionOption(id: 'b', label: 'B'),
        ],
      );

      await tester.pumpWidget(_app(
        child: ButterClarifyingQuestionCard(
          question: question,
          onSubmit: (ids, other) {
            submittedIds = ids;
            submittedOther = other;
          },
        ),
      ));

      // Tap option A.
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      // Submit should now be enabled.
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(submittedIds, ['a']);
      expect(submittedOther, isNull);
    });

    testWidgets('single select replaces previous selection', (tester) async {
      List<String>? submittedIds;

      const question = ButterClarifyingQuestion(
        questionText: 'Pick one',
        options: [
          ButterQuestionOption(id: 'a', label: 'A'),
          ButterQuestionOption(id: 'b', label: 'B'),
        ],
      );

      await tester.pumpWidget(_app(
        child: ButterClarifyingQuestionCard(
          question: question,
          onSubmit: (ids, _) => submittedIds = ids,
        ),
      ));

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(submittedIds, ['b']);
    });

    testWidgets('multiple select allows multiple selections', (tester) async {
      List<String>? submittedIds;

      const question = ButterClarifyingQuestion(
        questionText: 'Pick many',
        options: [
          ButterQuestionOption(id: 'a', label: 'A'),
          ButterQuestionOption(id: 'b', label: 'B'),
          ButterQuestionOption(id: 'c', label: 'C'),
        ],
        selectionMode: ButterSelectionMode.multiple,
      );

      await tester.pumpWidget(_app(
        child: ButterClarifyingQuestionCard(
          question: question,
          onSubmit: (ids, _) => submittedIds = ids,
        ),
      ));

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(submittedIds, containsAll(['a', 'c']));
      expect(submittedIds, isNot(contains('b')));
    });

    testWidgets('resolved state shows check icon and chips', (tester) async {
      const question = ButterClarifyingQuestion(
        questionText: 'What did you pick?',
        options: [
          ButterQuestionOption(id: 'a', label: 'Alpha'),
          ButterQuestionOption(id: 'b', label: 'Beta'),
        ],
        selectedOptionIds: ['a'],
        isResolved: true,
      );

      await tester.pumpWidget(_app(
        child: ButterClarifyingQuestionCard(
          question: question,
          onSubmit: (_, __) {},
        ),
      ));

      expect(find.text('What did you pick?'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      // Submit button should not be present in resolved state.
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('other text field shown when allowOther is true',
        (tester) async {
      List<String>? submittedIds;
      String? submittedOther;

      const question = ButterClarifyingQuestion(
        questionText: 'Pick',
        options: [
          ButterQuestionOption(id: 'a', label: 'A'),
        ],
        allowOther: true,
        otherLabel: 'Custom',
        otherHint: 'Type here',
      );

      await tester.pumpWidget(_app(
        child: ButterClarifyingQuestionCard(
          question: question,
          onSubmit: (ids, other) {
            submittedIds = ids;
            submittedOther = other;
          },
        ),
      ));

      expect(find.text('Custom'), findsOneWidget);

      // Type in the other field and submit (without selecting an option).
      await tester.enterText(
        find.byType(TextField),
        'My custom answer',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(submittedIds, isEmpty);
      expect(submittedOther, 'My custom answer');
    });
  });
}
