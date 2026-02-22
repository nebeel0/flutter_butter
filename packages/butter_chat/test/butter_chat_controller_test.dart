import 'package:butter_chat/butter_chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ButterChatController controller;

  setUp(() {
    controller = ButterChatController();
  });

  tearDown(() {
    controller.dispose();
  });

  group('initial state', () {
    test('starts with no messages', () {
      expect(controller.messages, isEmpty);
      expect(controller.activeMessages, isEmpty);
      expect(controller.isStreaming, isFalse);
      expect(controller.streamingMessage, isNull);
      expect(controller.statusLabel, isNull);
    });

    test('initialMessages populates the message map', () {
      final msg = ButterChatMessage(
        id: '1',
        role: ButterChatRole.user,
        content: 'Hello',
        createdAt: DateTime.now(),
      );
      final ctrl = ButterChatController(initialMessages: [msg]);
      expect(ctrl.messages, hasLength(1));
      expect(ctrl.messages['1']?.content, 'Hello');
      ctrl.dispose();
    });
  });

  group('addUserMessage', () {
    test('adds a user message and notifies', () {
      var notified = false;
      controller.addListener(() => notified = true);

      controller.addUserMessage(id: '1', content: 'Hello');

      expect(notified, isTrue);
      expect(controller.messages, hasLength(1));
      expect(controller.messages['1']?.role, ButterChatRole.user);
      expect(controller.messages['1']?.content, 'Hello');
      expect(controller.messages['1']?.status,
          ButterChatMessageStatus.complete);
    });

    test('auto-links to last active message when no parentId given', () {
      controller.addUserMessage(id: '1', content: 'First');
      controller.addAssistantMessage(id: '2', parentId: '1');
      controller.addUserMessage(id: '3', content: 'Second');

      // '3' should be linked as child of '2' (last active message).
      expect(controller.messages['2']?.childIds, contains('3'));
      expect(controller.messages['3']?.parentId, '2');
    });
  });

  group('addAssistantMessage', () {
    test('adds assistant message with pending status', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');

      expect(controller.messages['2']?.role, ButterChatRole.assistant);
      expect(controller.messages['2']?.content, '');
      expect(controller.messages['2']?.status,
          ButterChatMessageStatus.pending);
    });
  });

  group('streaming', () {
    test('appendContent appends tokens', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');

      controller.appendContent('2', 'Hello');
      controller.appendContent('2', ' World');

      expect(controller.messages['2']?.content, 'Hello World');
    });

    test('appendThinkingContent appends to thinking', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');

      controller.appendThinkingContent('2', 'Let me think');
      controller.appendThinkingContent('2', '...');

      expect(controller.messages['2']?.thinkingContent, 'Let me think...');
    });

    test('isStreaming returns true when message is streaming', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');
      controller.setMessageStatus('2', ButterChatMessageStatus.streaming);

      expect(controller.isStreaming, isTrue);
      expect(controller.streamingMessage?.id, '2');
    });

    test('isStreaming returns true when message is thinking', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');
      controller.setMessageStatus('2', ButterChatMessageStatus.thinking);

      expect(controller.isStreaming, isTrue);
    });

    test('stopStreaming sets status to stopped', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');
      controller.setMessageStatus('2', ButterChatMessageStatus.streaming);

      controller.stopStreaming();

      expect(controller.messages['2']?.status,
          ButterChatMessageStatus.stopped);
      expect(controller.isStreaming, isFalse);
    });

    test('appendContent is a no-op for nonexistent ID', () {
      controller.appendContent('nonexistent', 'token');
      expect(controller.messages, isEmpty);
    });
  });

  group('setMessageStatus', () {
    test('updates status and appends to history', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');

      controller.setMessageStatus(
          '2', ButterChatMessageStatus.thinking,
          label: 'Analyzing...');
      controller.setMessageStatus(
          '2', ButterChatMessageStatus.streaming);
      controller.setMessageStatus(
          '2', ButterChatMessageStatus.complete);

      final msg = controller.messages['2']!;
      expect(msg.status, ButterChatMessageStatus.complete);
      expect(msg.statusHistory, hasLength(3));
      expect(msg.statusHistory[0].status,
          ButterChatMessageStatus.thinking);
      expect(msg.statusHistory[0].label, 'Analyzing...');
      expect(msg.statusHistory[1].status,
          ButterChatMessageStatus.streaming);
      expect(msg.statusHistory[2].status,
          ButterChatMessageStatus.complete);
    });
  });

  group('statusLabel', () {
    test('sets and clears status label', () {
      controller.setStatusLabel('Searching...');
      expect(controller.statusLabel, 'Searching...');

      controller.setStatusLabel(null);
      expect(controller.statusLabel, isNull);
    });

    test('does not notify when label unchanged', () {
      controller.setStatusLabel('Test');
      var notified = false;
      controller.addListener(() => notified = true);
      controller.setStatusLabel('Test');
      expect(notified, isFalse);
    });
  });

  group('activeMessages', () {
    test('returns linear path through tree', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');
      controller.setMessageStatus('2', ButterChatMessageStatus.complete);
      controller.appendContent('2', 'Hi there');

      final active = controller.activeMessages;
      expect(active, hasLength(2));
      expect(active[0].id, '1');
      expect(active[1].id, '2');
    });

    test('follows active branch', () {
      // Build a branching tree:
      // root(1) -> user(2) -> assistant(3a)
      //                    -> assistant(3b) (active)
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '3a', parentId: '1');
      controller.addAssistantMessage(id: '3b', parentId: '1');

      // Parent '1' should now have activeChildIndex pointing to '3b'.
      final active = controller.activeMessages;
      expect(active.last.id, '3b');
    });
  });

  group('branching', () {
    test('editUserMessage creates sibling branch', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');

      // Now user wants to edit message '1'. Since '1' has no parent,
      // the new message is a root. Let's set up a proper tree:
      controller.addUserMessage(id: '3', content: 'Follow up');
      // '3' is a child of '2'.

      controller.editUserMessage('3', 'Edited follow up', newId: '3b');

      // '3b' should be a sibling of '3' under parent '2'.
      expect(controller.messages['2']?.childIds, contains('3'));
      expect(controller.messages['2']?.childIds, contains('3b'));
      expect(controller.messages['3b']?.content, 'Edited follow up');

      // Active child should point to the new branch.
      expect(controller.messages['2']?.activeChildIndex,
          controller.messages['2']?.childIds.indexOf('3b'));
    });

    test('regenerateResponse creates sibling branch', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');
      controller.appendContent('2', 'First response');
      controller.setMessageStatus('2', ButterChatMessageStatus.complete);

      controller.regenerateResponse('2', newId: '2b');

      expect(controller.messages['1']?.childIds, contains('2'));
      expect(controller.messages['1']?.childIds, contains('2b'));
      expect(controller.messages['2b']?.status,
          ButterChatMessageStatus.pending);

      // Active child should be the new one.
      expect(controller.messages['1']?.activeChildIndex,
          controller.messages['1']?.childIds.indexOf('2b'));
    });

    test('switchBranch changes active child', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2a', parentId: '1');
      controller.addAssistantMessage(id: '2b', parentId: '1');

      // Initially active is '2b' (last added).
      expect(controller.activeMessages.last.id, '2b');

      // Switch to first branch.
      controller.switchBranch('1', 0);
      expect(controller.activeMessages.last.id, '2a');

      // Switch back.
      controller.switchBranch('1', 1);
      expect(controller.activeMessages.last.id, '2b');
    });

    test('switchBranch ignores invalid index', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2', parentId: '1');

      var notified = false;
      controller.addListener(() => notified = true);
      controller.switchBranch('1', 5); // out of bounds
      expect(notified, isFalse);
    });

    test('switchBranch does not notify for same index', () {
      controller.addUserMessage(id: '1', content: 'Hello');
      controller.addAssistantMessage(id: '2a', parentId: '1');
      controller.addAssistantMessage(id: '2b', parentId: '1');

      var notified = false;
      controller.addListener(() => notified = true);
      // Current active is already index 1 (2b).
      controller.switchBranch('1', 1);
      expect(notified, isFalse);
    });
  });

  group('clarifying questions', () {
    test('addClarifyingQuestion creates assistant message with question', () {
      controller.addUserMessage(id: '1', content: 'Hello');

      const question = ButterClarifyingQuestion(
        questionText: 'Which option?',
        options: [
          ButterQuestionOption(id: 'a', label: 'A'),
          ButterQuestionOption(id: 'b', label: 'B'),
        ],
      );

      controller.addClarifyingQuestion(
        id: '2',
        question: question,
        parentId: '1',
        content: 'Before I proceed:',
      );

      final msg = controller.messages['2']!;
      expect(msg.role, ButterChatRole.assistant);
      expect(msg.content, 'Before I proceed:');
      expect(msg.status, ButterChatMessageStatus.complete);
      expect(msg.clarifyingQuestion, isNotNull);
      expect(msg.clarifyingQuestion!.questionText, 'Which option?');
      expect(msg.clarifyingQuestion!.options, hasLength(2));
      expect(msg.clarifyingQuestion!.isResolved, isFalse);
    });

    test('addClarifyingQuestion auto-links to last active message', () {
      controller.addUserMessage(id: '1', content: 'Hello');

      const question = ButterClarifyingQuestion(
        questionText: 'Q?',
        options: [ButterQuestionOption(id: 'a', label: 'A')],
      );

      controller.addClarifyingQuestion(id: '2', question: question);

      expect(controller.messages['2']!.parentId, '1');
      expect(controller.messages['1']!.childIds, contains('2'));
    });

    test('resolveClarifyingQuestion marks question as resolved', () {
      controller.addUserMessage(id: '1', content: 'Hello');

      const question = ButterClarifyingQuestion(
        questionText: 'Pick one',
        options: [
          ButterQuestionOption(id: 'a', label: 'A'),
          ButterQuestionOption(id: 'b', label: 'B'),
        ],
      );

      controller.addClarifyingQuestion(
        id: '2',
        question: question,
        parentId: '1',
      );

      controller.resolveClarifyingQuestion(
        '2',
        selectedOptionIds: ['b'],
        otherText: 'extra',
      );

      final resolved = controller.messages['2']!.clarifyingQuestion!;
      expect(resolved.isResolved, isTrue);
      expect(resolved.selectedOptionIds, ['b']);
      expect(resolved.otherText, 'extra');
    });

    test('resolveClarifyingQuestion is no-op for message without question',
        () {
      controller.addUserMessage(id: '1', content: 'Hello');

      var notified = false;
      controller.addListener(() => notified = true);

      controller.resolveClarifyingQuestion('1', selectedOptionIds: ['x']);
      expect(notified, isFalse);
    });

    test('resolveClarifyingQuestion is no-op for nonexistent message', () {
      var notified = false;
      controller.addListener(() => notified = true);

      controller.resolveClarifyingQuestion('nope', selectedOptionIds: ['x']);
      expect(notified, isFalse);
    });
  });

  group('tree structure', () {
    test('deep conversation chain', () {
      // Build: user1 -> assistant1 -> user2 -> assistant2
      controller.addUserMessage(id: 'u1', content: 'First');
      controller.addAssistantMessage(id: 'a1', parentId: 'u1');
      controller.appendContent('a1', 'Reply 1');
      controller.setMessageStatus('a1', ButterChatMessageStatus.complete);

      controller.addUserMessage(id: 'u2', content: 'Second');
      controller.addAssistantMessage(id: 'a2', parentId: 'u2');
      controller.appendContent('a2', 'Reply 2');
      controller.setMessageStatus('a2', ButterChatMessageStatus.complete);

      final active = controller.activeMessages;
      expect(active, hasLength(4));
      expect(active[0].id, 'u1');
      expect(active[1].id, 'a1');
      expect(active[2].id, 'u2');
      expect(active[3].id, 'a2');
    });
  });
}
