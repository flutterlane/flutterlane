import 'package:markdown/markdown.dart';

/// Matches fenced code blocks with language "mermaid".
///
/// Produces a custom element containing the diagram source code.
class MermaidSyntax extends BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^```mermaid\s*$');

  const MermaidSyntax();

  @override
  Node? parse(BlockParser parser) {
    final lines = <String>[];
    parser.advance();

    while (!parser.isDone) {
      final current = parser.current;
      if (current.content.trim() == '```') {
        parser.advance();
        break;
      }
      lines.add(current.content);
      parser.advance();
    }

    return Element('mermaid', [
      Element.text('code', lines.join('\n')),
    ]);
  }
}
