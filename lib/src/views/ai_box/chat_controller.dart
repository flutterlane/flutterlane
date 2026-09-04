import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Role of a chat message.
enum ChatMessageRole {
  user,
  assistant,
}

/// Status of a chat message (for streaming / loading states).
enum ChatMessageStatus {
  /// Message is complete and delivered.
  delivered,

  /// Message is still being generated (typing indicator).
  streaming,

  /// Message failed to send.
  error,
}

/// A single chat message.
class ChatMessage {
  final String id;
  final String content;
  final ChatMessageRole role;
  final DateTime timestamp;
  final ChatMessageStatus status;

  /// Optional metadata (e.g. model name, token count, references).
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.status = ChatMessageStatus.delivered,
    this.metadata,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    ChatMessageRole? role,
    DateTime? timestamp,
    ChatMessageStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          role == other.role;

  @override
  int get hashCode => id.hashCode ^ content.hashCode ^ role.hashCode;
}

/// Strategy pattern interface for feeding data into [AIChatBox].
///
/// Implement this class to provide your own message history, send logic,
/// and streaming support. The widget calls these methods to render the chat.
///
/// A minimal implementation only needs [messages] and [send]:
/// ```dart
/// class MyChatController extends ChatController {
///   final List<ChatMessage> _messages = [];
///
///   @override
///   List<ChatMessage> get messages => _messages;
///
///   @override
///   void send(String text) {
///     _messages.add(ChatMessage(
///       id: generateId(),
///       content: text,
///       role: ChatMessageRole.user,
///       timestamp: DateTime.now(),
///     ));
///     // Simulate AI response
///     Future.delayed(Duration(seconds: 1), () {
///       _messages.add(ChatMessage(
///         id: generateId(),
///         content: 'Echo: $text',
///         role: ChatMessageRole.assistant,
///         timestamp: DateTime.now(),
///       ));
///       notifyListeners();
///     });
///     notifyListeners();
///   }
/// }
/// ```
abstract class ChatController extends ChangeNotifier {
  /// Current list of messages.
  List<ChatMessage> get messages;

  /// Whether the assistant is currently generating a response.
  bool get isStreaming => false;

  /// Send a user message. The controller should add it to [messages]
  /// and optionally trigger an assistant response.
  void send(String text);

  /// Retry sending the last user message (on error).
  void retryLast() {}

  /// Clear all messages.
  void clear() {
    notifyListeners();
  }

  /// Copy all messages to clipboard.
  void copyToClipboard() {
    final buffer = StringBuffer();
    for (final msg in messages) {
      final role = msg.role == ChatMessageRole.user ? 'You' : 'Assistant';
      buffer.writeln('**$role**: ${msg.content}');
      buffer.writeln();
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  /// Export messages as a markdown string.
  String exportMarkdown() {
    final buffer = StringBuffer();
    for (final msg in messages) {
      final role = msg.role == ChatMessageRole.user ? 'You' : 'Assistant';
      buffer.writeln('### $role');
      buffer.writeln(msg.content);
      buffer.writeln();
    }
    return buffer.toString();
  }
}

/// A simple [ChatController] backed by an in-memory list.
///
/// For prototyping only — does not persist messages.
class SimpleChatController extends ChatController {
  final List<ChatMessage> _messages = [];
  bool _isStreaming = false;

  /// Optional callback invoked when the user sends a message.
  /// Use this to simulate or connect to your AI backend.
  final void Function(String text, SimpleChatController controller)? onSend;

  SimpleChatController({this.onSend});

  @override
  List<ChatMessage> get messages => _messages;

  @override
  bool get isStreaming => _isStreaming;

  @override
  void send(String text) {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      role: ChatMessageRole.user,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
    onSend?.call(text, this);
  }

  /// Add an assistant message (call this from your onSend callback).
  void addAssistantMessage(String content, {ChatMessageStatus status = ChatMessageStatus.delivered}) {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: ChatMessageRole.assistant,
      timestamp: DateTime.now(),
      status: status,
    ));
    notifyListeners();
  }

  /// Set the streaming state.
  set streaming(bool value) {
    _isStreaming = value;
    notifyListeners();
  }

  @override
  void clear() {
    _messages.clear();
    super.clear();
  }
}
