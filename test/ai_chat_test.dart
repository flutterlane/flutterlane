import 'package:flutter_test/flutter_test.dart';
import 'package:flutterlane/flutterlane.dart';

void main() {
  group('ChatMessage', () {
    test('creates with required fields', () {
      final msg = ChatMessage(
        id: '1',
        content: 'Hello',
        role: ChatMessageRole.user,
        timestamp: DateTime(2024),
      );

      expect(msg.id, '1');
      expect(msg.content, 'Hello');
      expect(msg.role, ChatMessageRole.user);
      expect(msg.status, ChatMessageStatus.delivered);
    });

    test('copyWith overrides specified fields', () {
      final original = ChatMessage(
        id: '1',
        content: 'Hello',
        role: ChatMessageRole.user,
        timestamp: DateTime(2024),
      );

      final copied = original.copyWith(
        content: 'Updated',
        status: ChatMessageStatus.streaming,
      );

      expect(copied.id, '1');
      expect(copied.content, 'Updated');
      expect(copied.status, ChatMessageStatus.streaming);
      expect(copied.role, ChatMessageRole.user);
    });

    test('equality by id, content, and role', () {
      final a = ChatMessage(
        id: '1',
        content: 'Hello',
        role: ChatMessageRole.user,
        timestamp: DateTime(2024),
      );
      final b = ChatMessage(
        id: '1',
        content: 'Hello',
        role: ChatMessageRole.user,
        timestamp: DateTime(2025),
      );
      final c = ChatMessage(
        id: '2',
        content: 'Hello',
        role: ChatMessageRole.user,
        timestamp: DateTime(2024),
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('SimpleChatController', () {
    test('starts with empty messages', () {
      final controller = SimpleChatController();
      expect(controller.messages, isEmpty);
      expect(controller.isStreaming, false);
    });

    test('send adds user message', () {
      final controller = SimpleChatController();
      controller.send('Hello');

      expect(controller.messages.length, 1);
      expect(controller.messages.first.content, 'Hello');
      expect(controller.messages.first.role, ChatMessageRole.user);
    });

    test('send notifies listeners', () {
      final controller = SimpleChatController();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.send('Test');
      expect(notified, true);
    });

    test('send invokes onSend callback', () {
      String? receivedText;
      final controller = SimpleChatController(
        onSend: (text, ctrl) => receivedText = text,
      );

      controller.send('Hello');
      expect(receivedText, 'Hello');
    });

    test('addAssistantMessage adds message', () {
      final controller = SimpleChatController();
      controller.addAssistantMessage('Response');

      expect(controller.messages.length, 1);
      expect(controller.messages.first.content, 'Response');
      expect(controller.messages.first.role, ChatMessageRole.assistant);
    });

    test('addAssistantMessage with streaming status', () {
      final controller = SimpleChatController();
      controller.addAssistantMessage('Partial', status: ChatMessageStatus.streaming);

      expect(controller.messages.first.status, ChatMessageStatus.streaming);
    });

    test('set streaming updates state', () {
      final controller = SimpleChatController();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.streaming = true;
      expect(controller.isStreaming, true);
      expect(notified, true);
    });

    test('clear removes all messages', () {
      final controller = SimpleChatController();
      controller.send('Hello');
      controller.addAssistantMessage('Response');

      controller.clear();
      expect(controller.messages, isEmpty);
    });

    test('copyToClipboard produces markdown string', () {
      final controller = SimpleChatController();
      controller.send('Hi');
      controller.addAssistantMessage('Hello');

      final md = controller.exportMarkdown();
      expect(md, contains('### You'));
      expect(md, contains('Hi'));
      expect(md, contains('### Assistant'));
      expect(md, contains('Hello'));
    });
  });
}
