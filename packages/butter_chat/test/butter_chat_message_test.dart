import 'package:butter_chat/butter_chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ButterChatMessage', () {
    test('creates with required fields', () {
      final now = DateTime.now();
      final msg = ButterChatMessage(
        id: '1',
        role: ButterChatRole.user,
        content: 'Hello',
        createdAt: now,
      );

      expect(msg.id, '1');
      expect(msg.role, ButterChatRole.user);
      expect(msg.content, 'Hello');
      expect(msg.parentId, isNull);
      expect(msg.childIds, isEmpty);
      expect(msg.activeChildIndex, 0);
      expect(msg.status, ButterChatMessageStatus.complete);
      expect(msg.statusHistory, isEmpty);
      expect(msg.thinkingContent, '');
      expect(msg.metadata, isEmpty);
      expect(msg.createdAt, now);
    });

    test('copyWith replaces specified fields', () {
      final msg = ButterChatMessage(
        id: '1',
        role: ButterChatRole.user,
        content: 'Hello',
        createdAt: DateTime(2026),
      );

      final updated = msg.copyWith(
        content: 'World',
        status: ButterChatMessageStatus.streaming,
        childIds: ['2', '3'],
        activeChildIndex: 1,
      );

      expect(updated.id, '1'); // unchanged
      expect(updated.content, 'World');
      expect(updated.status, ButterChatMessageStatus.streaming);
      expect(updated.childIds, ['2', '3']);
      expect(updated.activeChildIndex, 1);
      expect(updated.role, ButterChatRole.user); // unchanged
    });

    test('copyWith preserves all fields when no arguments given', () {
      final msg = ButterChatMessage(
        id: '1',
        role: ButterChatRole.assistant,
        content: 'test',
        parentId: 'parent',
        childIds: ['c1'],
        activeChildIndex: 0,
        status: ButterChatMessageStatus.thinking,
        thinkingContent: 'thinking...',
        metadata: {'key': 'value'},
        clarifyingQuestion: const ButterClarifyingQuestion(
          questionText: 'Q?',
          options: [ButterQuestionOption(id: 'a', label: 'A')],
        ),
        createdAt: DateTime(2026),
      );

      final copy = msg.copyWith();
      expect(copy.id, msg.id);
      expect(copy.role, msg.role);
      expect(copy.content, msg.content);
      expect(copy.parentId, msg.parentId);
      expect(copy.childIds, msg.childIds);
      expect(copy.activeChildIndex, msg.activeChildIndex);
      expect(copy.status, msg.status);
      expect(copy.thinkingContent, msg.thinkingContent);
      expect(copy.metadata, msg.metadata);
      expect(copy.clarifyingQuestion, msg.clarifyingQuestion);
      expect(copy.createdAt, msg.createdAt);
    });

    test('clarifyingQuestion defaults to null', () {
      final msg = ButterChatMessage(
        id: '1',
        role: ButterChatRole.user,
        content: 'Hello',
        createdAt: DateTime.now(),
      );

      expect(msg.clarifyingQuestion, isNull);
    });

    test('copyWith can set clarifyingQuestion', () {
      final msg = ButterChatMessage(
        id: '1',
        role: ButterChatRole.assistant,
        content: 'text',
        createdAt: DateTime.now(),
      );

      const question = ButterClarifyingQuestion(
        questionText: 'Pick',
        options: [ButterQuestionOption(id: 'x', label: 'X')],
      );

      final updated = msg.copyWith(clarifyingQuestion: question);
      expect(updated.clarifyingQuestion, isNotNull);
      expect(updated.clarifyingQuestion!.questionText, 'Pick');
    });
  });

  group('ButterChatStatusEntry', () {
    test('creates with required fields', () {
      final now = DateTime.now();
      final entry = ButterChatStatusEntry(
        status: ButterChatMessageStatus.streaming,
        timestamp: now,
        label: 'Generating...',
      );

      expect(entry.status, ButterChatMessageStatus.streaming);
      expect(entry.timestamp, now);
      expect(entry.label, 'Generating...');
    });
  });

  group('ButterChatRole', () {
    test('has all expected values', () {
      expect(ButterChatRole.values, hasLength(3));
      expect(ButterChatRole.values, contains(ButterChatRole.user));
      expect(ButterChatRole.values, contains(ButterChatRole.assistant));
      expect(ButterChatRole.values, contains(ButterChatRole.system));
    });
  });

  group('ButterChatMessageStatus', () {
    test('has all expected values', () {
      expect(ButterChatMessageStatus.values, hasLength(6));
      expect(ButterChatMessageStatus.values,
          contains(ButterChatMessageStatus.pending));
      expect(ButterChatMessageStatus.values,
          contains(ButterChatMessageStatus.streaming));
      expect(ButterChatMessageStatus.values,
          contains(ButterChatMessageStatus.thinking));
      expect(ButterChatMessageStatus.values,
          contains(ButterChatMessageStatus.complete));
      expect(ButterChatMessageStatus.values,
          contains(ButterChatMessageStatus.stopped));
      expect(ButterChatMessageStatus.values,
          contains(ButterChatMessageStatus.error));
    });
  });
}
