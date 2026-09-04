import 'package:flutter/material.dart';

import 'markdown_renderer.dart';
import 'markdown_theme.dart';

/// Controller for the markdown editor/preview.
///
/// Manages the document text and notifies listeners on changes.
/// Implement this to provide your own persistence, undo/redo, etc.
///
/// Minimal usage:
/// ```dart
/// final controller = MarkdownController(initialText: '# Hello\nWorld');
/// // Widget reads controller.text automatically
/// controller.text = '## Updated';
/// // Widget rebuilds automatically
/// ```
class MarkdownController extends ChangeNotifier {
  String _text;

  MarkdownController({String initialText = ''}) : _text = initialText;

  /// The current markdown source text.
  String get text => _text;

  /// Set the full document text.
  set text(String value) {
    if (_text != value) {
      _text = value;
      notifyListeners();
    }
  }

  /// Append text to the document.
  void append(String additionalText) {
    _text += additionalText;
    notifyListeners();
  }

  /// Replace text in a range.
  void replaceRange(int start, int end, String replacement) {
    final chars = _text.split('');
    chars.replaceRange(start, end, replacement.split(''));
    _text = chars.join();
    notifyListeners();
  }
}

/// Display mode for the markdown editor/preview widget.
enum MarkdownDisplayMode {
  /// Side-by-side editor (left) and preview (right).
  split,

  /// Tabbed mode: switch between 'Editor' and 'Preview' tabs.
  tabbed,
}

/// A markdown editor/preview widget with split and tabbed display modes.
///
/// Provide a [MarkdownController] to manage the text content.
/// The widget automatically rebuilds when the controller's text changes.
///
/// Features:
/// - **Split mode**: resizable side-by-side editor + live preview
/// - **Tabbed mode**: toggle between editor and preview with tabs
/// - **Live preview**: markdown renders in real-time as you type
/// - **Themed**: uses FlutterLaneTheme for consistent styling
class MarkdownEditorPreview extends StatefulWidget {
  final MarkdownController controller;
  final MarkdownDisplayMode mode;

  /// Custom markdown renderer. Defaults to [DefaultMarkdownWidget].
  final Widget Function(String markdown)? markdownBuilder;

  /// Custom editor decorations (e.g. syntax highlighting).
  final InputDecoration? editorDecoration;

  /// Font size for the editor. Defaults to 13.
  final double editorFontSize;

  /// Padding inside editor/preview panes. Defaults to 16.
  final double contentPadding;

  const MarkdownEditorPreview({
    super.key,
    required this.controller,
    this.mode = MarkdownDisplayMode.split,
    this.markdownBuilder,
    this.editorDecoration,
    this.editorFontSize = 13,
    this.contentPadding = 16,
  });

  @override
  State<MarkdownEditorPreview> createState() => _MarkdownEditorPreviewState();
}

class _MarkdownEditorPreviewState extends State<MarkdownEditorPreview>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _splitRatio = 0.5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(covariant MarkdownEditorPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChange);
      widget.controller.addListener(_onTextChange);
    }
    if (oldWidget.mode != widget.mode) {
      _tabController.dispose();
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChange);
    _tabController.dispose();
    super.dispose();
  }

  void _onTextChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == MarkdownDisplayMode.tabbed) {
      return _buildTabbed();
    }
    return _buildSplit();
  }

  Widget _buildTabbed() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Editor'),
            Tab(text: 'Preview'),
          ],
          isScrollable: true,
          tabAlignment: TabAlignment.start,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEditor(),
              _buildPreview(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSplit() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final editorWidth = totalWidth * _splitRatio;
        final previewWidth = totalWidth - editorWidth - 4;

        return Row(
          children: [
            SizedBox(
              width: editorWidth,
              child: _buildEditor(),
            ),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _splitRatio =
                      (editorWidth + details.delta.dx) / totalWidth;
                  _splitRatio = _splitRatio.clamp(0.2, 0.8);
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: Container(
                  width: 4,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            SizedBox(
              width: previewWidth,
              child: _buildPreview(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditor() {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: EdgeInsets.all(widget.contentPadding),
      child: TextField(
        controller: TextEditingController(text: widget.controller.text)
          ..selection = TextSelection.collapsed(
            offset: widget.controller.text.length,
          ),
        onChanged: (value) => widget.controller.text = value,
        maxLines: null,
        expands: true,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: widget.editorFontSize,
          color: const Color(0xFFD4D4D4),
          height: 1.5,
        ),
        decoration: widget.editorDecoration ??
            const InputDecoration(
              border: InputBorder.none,
              hintText: 'Write markdown here...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      color: const Color(0xFF252526),
      padding: EdgeInsets.all(widget.contentPadding),
      child: widget.markdownBuilder != null
          ? widget.markdownBuilder!(widget.controller.text)
          : MarkdownRenderer(
              data: widget.controller.text,
              theme: MarkdownThemeData.dark,
            ),
    );
  }
}

/// Simple default markdown renderer.
///
/// Renders a subset of markdown: headings, bold, italic, code blocks,
/// bullet lists, and blockquotes. For full markdown support, provide
/// a custom [MarkdownEditorPreview.markdownBuilder].
class DefaultMarkdownWidget extends StatelessWidget {
  final String text;

  const DefaultMarkdownWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const Text(
        'Nothing to preview',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    final lines = text.split('\n');
    final widgets = <Widget>[];
    bool inCodeBlock = false;
    final codeLines = <String>[];

    for (final line in lines) {
      if (line.trim() == '```') {
        if (inCodeBlock) {
          widgets.add(_buildCodeBlock(codeLines.join('\n')));
          codeLines.clear();
          inCodeBlock = false;
        } else {
          inCodeBlock = true;
        }
        continue;
      }

      if (inCodeBlock) {
        codeLines.add(line);
        continue;
      }

      widgets.add(_buildLine(line));
      widgets.add(const SizedBox(height: 4));
    }

    if (inCodeBlock && codeLines.isNotEmpty) {
      widgets.add(_buildCodeBlock(codeLines.join('\n')));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _buildLine(String line) {
    if (line.startsWith('### ')) {
      return _styledText(line.substring(4), fontSize: 16, bold: true);
    }
    if (line.startsWith('## ')) {
      return _styledText(line.substring(3), fontSize: 18, bold: true);
    }
    if (line.startsWith('# ')) {
      return _styledText(line.substring(2), fontSize: 22, bold: true);
    }
    if (line.startsWith('> ')) {
      return Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.blue.shade400, width: 3),
          ),
        ),
        child: _styledText(line.substring(2), italic: true, color: Colors.grey),
      );
    }
    if (line.startsWith('- ') || line.startsWith('* ')) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(child: _styledText(line.substring(2))),
        ],
      );
    }

    return _styledText(line);
  }

  Widget _styledText(
    String text, {
    double fontSize = 14,
    bool bold = false,
    bool italic = false,
    Color? color,
  }) {
    // Handle inline code
    if (text.contains('`')) {
      final spans = <TextSpan>[];
      final parts = text.split('`');
      for (var i = 0; i < parts.length; i++) {
        if (i.isEven) {
          spans.add(TextSpan(
            text: parts[i],
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              color: color ?? Colors.white70,
            ),
          ));
        } else {
          spans.add(TextSpan(
            text: parts[i],
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: fontSize,
              backgroundColor: Colors.white10,
              color: Colors.orange.shade300,
            ),
          ));
        }
      }
      return RichText(text: TextSpan(children: spans));
    }

    // Handle **bold**
    if (text.contains('**')) {
      final spans = <TextSpan>[];
      final parts = text.split('**');
      for (var i = 0; i < parts.length; i++) {
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: i.isOdd ? FontWeight.bold : FontWeight.normal,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: color ?? Colors.white70,
          ),
        ));
      }
      return RichText(text: TextSpan(children: spans));
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        color: color ?? Colors.white70,
        height: 1.5,
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Color(0xFFD4D4D4),
          height: 1.5,
        ),
      ),
    );
  }
}
