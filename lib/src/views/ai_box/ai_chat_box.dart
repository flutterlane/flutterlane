import 'package:flutter/material.dart';

import '../../theme/flutter_lane_theme.dart';
import 'chat_controller.dart';

/// A copilot-style chat UI widget.
///
/// Displays a scrollable thread of messages with user/assistant bubbles,
/// a typing indicator for streaming responses, and a send bar at the bottom.
///
/// Provide a [ChatController] to manage your message data and send logic.
///
/// ```dart
/// AIChatBox(
///   controller: myChatController,
///   title: 'Copilot',
///   placeholder: 'Ask a question...',
/// )
/// ```
class AIChatBox extends StatefulWidget {
  final ChatController controller;

  /// Title shown at the top of the chat box.
  final String? title;

  /// Placeholder text for the input field.
  final String placeholder;

  /// Maximum number of suggestions shown below the welcome message.
  final int maxSuggestions;

  /// Welcome suggestions shown when the chat is empty.
  final List<String> suggestions;

  /// Whether to show the toolbar (clear, export) at the top.
  final bool showToolbar;

  const AIChatBox({
    super.key,
    required this.controller,
    this.title,
    this.placeholder = 'Ask a question...',
    this.maxSuggestions = 3,
    this.suggestions = const [],
    this.showToolbar = true,
  });

  @override
  State<AIChatBox> createState() => _AIChatBoxState();
}

class _AIChatBoxState extends State<AIChatBox> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(covariant AIChatBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerUpdate);
      widget.controller.addListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    widget.controller.send(text);
    _inputFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);
    final messages = widget.controller.messages;
    final isStreaming = widget.controller.isStreaming;
    final isEmpty = messages.isEmpty;

    return Container(
      color: theme.sectionBackground,
      child: Column(
        children: [
          if (widget.showToolbar || widget.title != null)
            _buildHeader(theme, messages),
          Expanded(
            child: isEmpty
                ? _buildEmptyState(theme)
                : _buildMessageList(theme, messages),
          ),
          _buildSendBar(theme, isStreaming),
        ],
      ),
    );
  }

  Widget _buildHeader(FlutterLaneThemeData theme, List<ChatMessage> messages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.tabBorderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (widget.title != null) ...[
            const Icon(Icons.auto_fix_high_rounded,
                size: 14, color: Colors.indigoAccent),
            const SizedBox(width: 6),
            Text(
              widget.title!,
              style: TextStyle(
                color: theme.sectionHeaderTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Spacer(),
          if (widget.showToolbar) ...[
            IconButton(
              icon: const Icon(Icons.content_copy, size: 14),
              tooltip: 'Copy',
              onPressed: messages.isEmpty ? null : () => widget.controller.copyToClipboard(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.download, size: 14),
              tooltip: 'Export',
              onPressed: messages.isEmpty ? null : () => _exportChat(theme),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 14),
              tooltip: 'Clear',
              onPressed: messages.isEmpty ? null : () => widget.controller.clear(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ],
      ),
    );
  }

  void _exportChat(FlutterLaneThemeData theme) {
    final md = widget.controller.exportMarkdown();
    // Show a brief snackbar with the exported content
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat exported (${md.length} chars)',
            style: TextStyle(color: theme.tabActiveTextColor)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildEmptyState(FlutterLaneThemeData theme) {
    final displaySuggestions =
        widget.suggestions.take(widget.maxSuggestions).toList();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_fix_high_rounded,
                size: 32, color: theme.tabInactiveTextColor),
            const SizedBox(height: 12),
            Text(
              widget.title ?? 'Chat',
              style: TextStyle(
                color: theme.sectionHeaderTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask questions, get help with your code, or explore ideas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.tabInactiveTextColor,
                fontSize: 12,
              ),
            ),
            if (displaySuggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displaySuggestions.map((s) {
                  return GestureDetector(
                    onTap: () {
                      _inputController.text = s;
                      _send();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.tabActiveBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: theme.tabBorderColor, width: 1),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.tabInactiveTextColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(
      FlutterLaneThemeData theme, List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isLast = index == messages.length - 1;
        final showIndicator =
            isLast && msg.role == ChatMessageRole.assistant && widget.controller.isStreaming;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMessageBubble(msg, theme),
              if (showIndicator) _buildTypingIndicator(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, FlutterLaneThemeData theme) {
    final isUser = msg.role == ChatMessageRole.user;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isUser
                ? Colors.blue.shade600
                : Colors.indigoAccent.withAlpha(50),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            isUser ? Icons.person : Icons.auto_fix_high_rounded,
            size: 14,
            color: isUser ? Colors.white : Colors.indigoAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? 'You' : 'Assistant',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.tabInactiveTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isUser
                      ? theme.tabActiveBackground
                      : theme.tabBarBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.tabBorderColor, width: 1),
                ),
                child: Text(
                  msg.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.tabActiveTextColor,
                    height: 1.5,
                  ),
                ),
              ),
              if (msg.status == ChatMessageStatus.error)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          size: 12, color: Colors.red.shade400),
                      const SizedBox(width: 4),
                      Text(
                        'Failed to send',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => widget.controller.retryLast(),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade400,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator(FlutterLaneThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.tabInactiveTextColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Thinking...',
            style: TextStyle(
              fontSize: 11,
              color: theme.tabInactiveTextColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendBar(FlutterLaneThemeData theme, bool isStreaming) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.tabBorderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.tabActiveBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.tabBorderColor, width: 1),
              ),
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocusNode,
                maxLines: null,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.tabActiveTextColor,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.placeholder,
                  hintStyle: TextStyle(
                    color: theme.tabInactiveTextColor,
                    fontSize: 12,
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isStreaming ? null : _send,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isStreaming
                    ? theme.tabInactiveTextColor
                    : Colors.indigoAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.send_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
