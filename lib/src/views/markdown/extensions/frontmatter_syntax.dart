import 'package:markdown/markdown.dart';

/// Parses YAML/TOML frontmatter blocks at the top of a Markdown document.
///
/// Syntax:
/// ```
/// ---
/// title: My Document
/// author: FlutterLane
/// ---
/// ```
class FrontmatterSyntax extends BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^---\s*$');

  const FrontmatterSyntax();

  @override
  Node? parse(BlockParser parser) {
    final lines = <String>[];
    parser.advance();

    while (!parser.isDone) {
      final current = parser.current.content;
      if (current.trim() == '---') {
        parser.advance();
        break;
      }
      lines.add(current);
      parser.advance();
    }

    return Element('frontmatter', [Element.text('code', lines.join('\n'))]);
  }
}

/// A node representing parsed frontmatter metadata.
class FrontmatterNode extends Element {
  final String frontmatter;

  FrontmatterNode({required this.frontmatter})
      : super('frontmatter', [Element.text('code', frontmatter)]);

  /// Parse the frontmatter string into a Map.
  Map<String, String> get metadata {
    final result = <String, String>{};
    for (final line in frontmatter.split('\n')) {
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 1).trim();
        if (key.isNotEmpty) {
          result[key] = value;
        }
      }
    }
    return result;
  }
}
