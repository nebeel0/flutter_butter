import 'package:butter_chat/butter_chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ButterQuestionOption', () {
    test('creates with required fields', () {
      const option = ButterQuestionOption(
        id: 'opt1',
        label: 'Option 1',
      );

      expect(option.id, 'opt1');
      expect(option.label, 'Option 1');
      expect(option.description, isNull);
    });

    test('creates with description', () {
      const option = ButterQuestionOption(
        id: 'opt1',
        label: 'Option 1',
        description: 'A description',
      );

      expect(option.description, 'A description');
    });
  });

  group('ButterSelectionMode', () {
    test('has all expected values', () {
      expect(ButterSelectionMode.values, hasLength(2));
      expect(ButterSelectionMode.values, contains(ButterSelectionMode.single));
      expect(
          ButterSelectionMode.values, contains(ButterSelectionMode.multiple));
    });
  });

  group('ButterClarifyingQuestion', () {
    test('creates with required fields and defaults', () {
      const question = ButterClarifyingQuestion(
        questionText: 'What do you prefer?',
        options: [
          ButterQuestionOption(id: 'a', label: 'A'),
          ButterQuestionOption(id: 'b', label: 'B'),
        ],
      );

      expect(question.questionText, 'What do you prefer?');
      expect(question.options, hasLength(2));
      expect(question.selectionMode, ButterSelectionMode.single);
      expect(question.allowOther, isFalse);
      expect(question.otherLabel, 'Other');
      expect(question.otherHint, 'Type your answer...');
      expect(question.selectedOptionIds, isEmpty);
      expect(question.otherText, isNull);
      expect(question.isResolved, isFalse);
    });

    test('copyWith replaces specified fields', () {
      const question = ButterClarifyingQuestion(
        questionText: 'Pick one',
        options: [
          ButterQuestionOption(id: 'a', label: 'A'),
        ],
      );

      final updated = question.copyWith(
        selectedOptionIds: ['a'],
        isResolved: true,
        otherText: 'custom',
      );

      expect(updated.questionText, 'Pick one'); // unchanged
      expect(updated.selectedOptionIds, ['a']);
      expect(updated.isResolved, isTrue);
      expect(updated.otherText, 'custom');
    });

    test('copyWith preserves all fields when no arguments given', () {
      const question = ButterClarifyingQuestion(
        questionText: 'Q?',
        options: [
          ButterQuestionOption(id: 'x', label: 'X', description: 'desc'),
        ],
        selectionMode: ButterSelectionMode.multiple,
        allowOther: true,
        otherLabel: 'Custom',
        otherHint: 'Type here',
        selectedOptionIds: ['x'],
        otherText: 'other',
        isResolved: true,
      );

      final copy = question.copyWith();
      expect(copy.questionText, question.questionText);
      expect(copy.options, question.options);
      expect(copy.selectionMode, question.selectionMode);
      expect(copy.allowOther, question.allowOther);
      expect(copy.otherLabel, question.otherLabel);
      expect(copy.otherHint, question.otherHint);
      expect(copy.selectedOptionIds, question.selectedOptionIds);
      expect(copy.otherText, question.otherText);
      expect(copy.isResolved, question.isResolved);
    });
  });

  group('ButterChatSession', () {
    test('creates with required fields and defaults', () {
      const session = ButterChatSession(
        id: 's1',
        title: 'Test Chat',
      );

      expect(session.id, 's1');
      expect(session.title, 'Test Chat');
      expect(session.subtitle, isNull);
      expect(session.createdAt, isNull);
      expect(session.updatedAt, isNull);
      expect(session.isPinned, isFalse);
    });

    test('creates with all fields', () {
      final now = DateTime.now();
      final session = ButterChatSession(
        id: 's1',
        title: 'Test',
        subtitle: 'Sub',
        createdAt: now,
        updatedAt: now,
        isPinned: true,
      );

      expect(session.subtitle, 'Sub');
      expect(session.createdAt, now);
      expect(session.updatedAt, now);
      expect(session.isPinned, isTrue);
    });

    test('copyWith replaces specified fields', () {
      const session = ButterChatSession(
        id: 's1',
        title: 'Original',
      );

      final updated = session.copyWith(
        title: 'Renamed',
        isPinned: true,
      );

      expect(updated.id, 's1'); // unchanged
      expect(updated.title, 'Renamed');
      expect(updated.isPinned, isTrue);
    });

    test('copyWith preserves all fields when no arguments given', () {
      final now = DateTime.now();
      final session = ButterChatSession(
        id: 's1',
        title: 'Test',
        subtitle: 'Sub',
        createdAt: now,
        updatedAt: now,
        isPinned: true,
      );

      final copy = session.copyWith();
      expect(copy.id, session.id);
      expect(copy.title, session.title);
      expect(copy.subtitle, session.subtitle);
      expect(copy.createdAt, session.createdAt);
      expect(copy.updatedAt, session.updatedAt);
      expect(copy.isPinned, session.isPinned);
    });
  });
}
