import 'package:markdown/markdown.dart';

/// Matches display LaTeX math: `$$...$$`
///
/// Produces a custom element containing the LaTeX expression.
class MathBlockSyntax extends BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^\$\$\s*$');

  const MathBlockSyntax();

  @override
  Node? parse(BlockParser parser) {
    final lines = <String>[];
    parser.advance();

    while (!parser.isDone) {
      final current = parser.current.content.trim();
      if (current == r'$$' || current.endsWith(r'$$')) {
        if (current.endsWith(r'$$') && current.length > 2) {
          lines.add(current.substring(0, current.length - 2));
        }
        parser.advance();
        break;
      }
      lines.add(parser.current.content);
      parser.advance();
    }

    return Element('math-block', [
      Element.text('code', lines.join('\n').trim()),
    ]);
  }
}
