import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

import 'extensions/math_inline_syntax.dart';
import 'extensions/math_block_syntax.dart';
import 'extensions/callout_syntax.dart';
import 'extensions/mermaid_syntax.dart';
import 'extensions/frontmatter_syntax.dart';
import 'builders/code_block_builder.dart';
import 'builders/math_builder.dart';
import 'builders/table_builder.dart';
import 'builders/mermaid_builder.dart';
import 'markdown_theme.dart';

/// A rich Markdown renderer for Flutter with education-focused features.
///
/// Parses Markdown with custom extensions (frontmatter, LaTeX math, callouts,
/// Mermaid diagrams) and renders them as Flutter widgets.
class MarkdownRenderer extends StatelessWidget {
  final String data;
  final MarkdownThemeData theme;

  const MarkdownRenderer({
    super.key,
    required this.data,
    this.theme = MarkdownThemeData.dark,
  });

  @override
  Widget build(BuildContext context) {
    if (data.trim().isEmpty) {
      return Text(
        'Nothing to preview',
        style: TextStyle(
          color: theme.textColor.withAlpha(120),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [
        md.InlineHtmlSyntax(),
        md.AutolinkExtensionSyntax(),
        md.EmojiSyntax(),
        md.StrikethroughSyntax(),
        MathInlineSyntax(),
      ],
      blockSyntaxes: [
        const md.FencedCodeBlockSyntax(),
        const md.TableSyntax(),
        const md.HeaderWithIdSyntax(),
        const md.SetextHeaderWithIdSyntax(),
        const FrontmatterSyntax(),
        const MathBlockSyntax(),
        const CalloutSyntax(),
        const MermaidSyntax(),
      ],
    );

    final nodes = document.parse(data);
    return _buildNodes(nodes);
  }

  Widget _buildNodes(List<md.Node> nodes) {
    final widgets = <Widget>[];
    for (final node in nodes) {
      final widget = _buildNode(node);
      if (widget != null) widgets.add(widget);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget? _buildNode(md.Node? node) {
    if (node == null) return null;
    if (node is md.Text) {
      return Text(
        node.text,
        style: TextStyle(fontSize: 14, color: theme.textColor, height: 1.6),
      );
    }
    if (node is md.Element) return _buildElement(node);
    return null;
  }

  List<Widget> _buildChildren(md.Element element) {
    final children = element.children;
    if (children == null) return [];
    return children.map(_buildNode).whereType<Widget>().toList();
  }

  String _collectText(md.Node? node) {
    if (node == null) return '';
    if (node is md.Text) return node.text;
    if (node is md.Element) {
      return (node.children ?? []).map(_collectText).join();
    }
    return '';
  }

  Widget _buildElement(md.Element element) {
    switch (element.tag) {
      case 'h1': return _buildHeading(element, 28, FontWeight.w700);
      case 'h2': return _buildHeading(element, 24, FontWeight.w600);
      case 'h3': return _buildHeading(element, 20, FontWeight.w600);
      case 'h4': return _buildHeading(element, 18, FontWeight.w600);
      case 'h5': return _buildHeading(element, 16, FontWeight.w500);
      case 'h6': return _buildHeading(element, 14, FontWeight.w500);
      case 'p': return _buildParagraph(element);
      case 'ul': return _buildList(element, false);
      case 'ol': return _buildList(element, true);
      case 'blockquote': return _buildBlockquote(element);
      case 'pre': return _buildCodeBlock(element);
      case 'hr': return _buildHr();
      case 'table': return _buildTable(element);
      case 'a': return _buildLink(element);
      case 'strong': return _buildStyledText(element, fontWeight: FontWeight.bold);
      case 'em': return _buildStyledText(element, fontStyle: FontStyle.italic);
      case 'del': return _buildStyledText(element, decoration: TextDecoration.lineThrough);
      case 'code': return _buildInlineCode(element);
      case 'img': return _buildImage(element);
      case 'frontmatter': return _buildFrontmatter(element);
      case 'math-block': return _buildMathBlock(element);
      case 'math-inline': return _buildMathInline(element);
      case 'callout': return _buildCallout(element);
      case 'mermaid': return _buildMermaid(element);
      default: return Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildChildren(element));
    }
  }

  Widget _buildHeading(md.Element element, double size, FontWeight weight) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        _collectText(element),
        style: TextStyle(fontSize: size, fontWeight: weight, color: theme.headingColor, height: 1.3),
      ),
    );
  }

  Widget _buildParagraph(md.Element element) {
    final spans = <InlineSpan>[];
    for (final child in (element.children ?? [])) {
      spans.addAll(_collectInlineSpans(child));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14, color: theme.textColor, height: 1.6),
          children: spans,
        ),
      ),
    );
  }

  List<InlineSpan> _collectInlineSpans(md.Node? node) {
    if (node == null) return [];
    if (node is md.Text) return [TextSpan(text: node.text)];
    if (node is md.Element) {
      switch (node.tag) {
        case 'strong': return [TextSpan(text: _collectText(node), style: const TextStyle(fontWeight: FontWeight.bold))];
        case 'em': return [TextSpan(text: _collectText(node), style: const TextStyle(fontStyle: FontStyle.italic))];
        case 'del': return [TextSpan(text: _collectText(node), style: const TextStyle(decoration: TextDecoration.lineThrough))];
        case 'a':
          return [TextSpan(text: _collectText(node), style: TextStyle(color: theme.linkColor, decoration: TextDecoration.underline))];
        case 'code':
          return [TextSpan(text: _collectText(node), style: TextStyle(fontFamily: 'monospace', fontSize: 13, backgroundColor: theme.codeBlockBackground, color: theme.codeBlockTextColor))];
        default: return [TextSpan(text: _collectText(node))];
      }
    }
    return [const TextSpan(text: '')];
  }

  Widget _buildList(md.Element element, bool ordered) {
    final items = <Widget>[];
    int index = 1;
    for (final child in (element.children ?? [])) {
      if (child is md.Element && child.tag == 'li') {
        items.add(_buildListItem(child, ordered ? index : null));
        index++;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
    );
  }

  Widget _buildListItem(md.Element element, int? index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index != null)
            Text('$index. ', style: TextStyle(fontSize: 14, color: theme.textColor, fontWeight: FontWeight.w500))
          else
            Text('• ', style: TextStyle(fontSize: 14, color: theme.listBulletColor)),
          Expanded(child: _buildParagraph(element)),
        ],
      ),
    );
  }

  Widget _buildBlockquote(md.Element element) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.blockquoteBorderColor, width: 3)),
      ),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 14, color: theme.blockquoteTextColor, fontStyle: FontStyle.italic, height: 1.6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildChildren(element)),
      ),
    );
  }

  Widget _buildCodeBlock(md.Element element) {
    String? language;
    String code = '';
    final children = element.children ?? [];
    if (children.isNotEmpty) {
      final firstChild = children.first;
      if (firstChild is md.Element && firstChild.tag == 'code') {
        final classAttr = firstChild.attributes['class'] ?? '';
        if (classAttr.startsWith('language-')) language = classAttr.substring(9);
        code = _collectText(firstChild);
      } else {
        code = _collectText(element);
      }
    }
    return CodeBlockBuilder.build(code: code, language: language, theme: theme);
  }

  Widget _buildHr() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(height: 1, color: theme.hrColor),
    );
  }

  Widget _buildTable(md.Element element) {
    final headers = <String>[];
    final alignments = <Alignment>[];
    final rows = <List<String>>[];

    for (final child in (element.children ?? [])) {
      if (child is md.Element) {
        if (child.tag == 'thead') {
          for (final row in (child.children ?? [])) {
            if (row is md.Element && row.tag == 'tr') {
              for (final cell in (row.children ?? [])) {
                if (cell is md.Element) {
                  headers.add(_collectText(cell));
                  final align = cell.attributes['style'];
                  if (align != null && align.contains('center')) {
                    alignments.add(Alignment.center);
                  } else if (align != null && align.contains('right')) {
                    alignments.add(Alignment.centerRight);
                  } else {
                    alignments.add(Alignment.centerLeft);
                  }
                }
              }
            }
          }
        } else if (child.tag == 'tbody') {
          for (final row in (child.children ?? [])) {
            if (row is md.Element && row.tag == 'tr') {
              final cells = <String>[];
              for (final cell in (row.children ?? [])) {
                if (cell is md.Element) cells.add(_collectText(cell));
              }
              if (cells.isNotEmpty) rows.add(cells);
            }
          }
        }
      }
    }
    return TableBuilder.build(headers: headers, alignments: alignments, rows: rows, theme: theme);
  }

  Widget _buildLink(md.Element element) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        _collectText(element),
        style: TextStyle(fontSize: 14, color: theme.linkColor, decoration: TextDecoration.underline),
      ),
    );
  }

  Widget _buildStyledText(md.Element element, {FontWeight? fontWeight, FontStyle? fontStyle, TextDecoration? decoration}) {
    return Text(
      _collectText(element),
      style: TextStyle(
        fontSize: 14, color: theme.textColor, height: 1.6,
        fontWeight: fontWeight, fontStyle: fontStyle, decoration: decoration,
      ),
    );
  }

  Widget _buildInlineCode(md.Element element) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.codeBlockBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.codeBlockBorderColor, width: 1),
      ),
      child: Text(
        _collectText(element),
        style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: theme.codeBlockTextColor),
      ),
    );
  }

  Widget _buildImage(md.Element element) {
    final alt = element.attributes['alt'] ?? '';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.codeBlockBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.codeBlockBorderColor),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 32, color: theme.textColor.withAlpha(100)),
            const SizedBox(height: 8),
            Text(alt.isNotEmpty ? alt : 'Image', style: TextStyle(fontSize: 12, color: theme.textColor.withAlpha(150))),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontmatter(md.Element element) {
    final raw = _collectText(element);
    final metadata = <String, String>{};
    for (final line in raw.split('\n')) {
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 1).trim();
        if (key.isNotEmpty) metadata[key] = value;
      }
    }
    if (metadata.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.codeBlockBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.codeBlockBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: metadata.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${e.key}: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.headingColor)),
                Expanded(child: Text(e.value, style: TextStyle(fontSize: 12, color: theme.textColor))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMathBlock(md.Element element) {
    return MathBuilder.buildBlock(latex: _collectText(element), theme: theme);
  }

  Widget _buildMathInline(md.Element element) {
    return MathBuilder.buildInline(latex: _collectText(element), theme: theme);
  }

  Widget _buildCallout(md.Element element) {
    final raw = _collectText(element);
    final lines = raw.split('\n');
    final typeStr = lines.first.trim();
    final content = lines.skip(1).join('\n').trim();

    CalloutType calloutType;
    try {
      calloutType = CalloutType.values.firstWhere((t) => t.name.toUpperCase() == typeStr.toUpperCase());
    } catch (_) {
      calloutType = CalloutType.note;
    }

    Color bgColor;
    Color borderColor;
    switch (calloutType) {
      case CalloutType.note: bgColor = theme.calloutNoteBackground; borderColor = theme.calloutNoteBorderColor;
      case CalloutType.tip: bgColor = theme.calloutTipBackground; borderColor = theme.calloutTipBorderColor;
      case CalloutType.warning: bgColor = theme.calloutWarningBackground; borderColor = theme.calloutWarningBorderColor;
      case CalloutType.caution: bgColor = theme.calloutCautionBackground; borderColor = theme.calloutCautionBorderColor;
      case CalloutType.important: bgColor = theme.calloutImportantBackground; borderColor = theme.calloutImportantBorderColor;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(calloutType.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(calloutType.name.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: borderColor, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(content, style: TextStyle(fontSize: 13, color: theme.calloutTextColor, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMermaid(md.Element element) {
    return MermaidBuilder.build(source: _collectText(element), theme: theme);
  }
}
