import 'package:markdown/markdown.dart';

/// Matches inline LaTeX math: `$...$`
///
/// Produces a custom element containing the LaTeX expression.
class MathInlineSyntax extends InlineSyntax {
  MathInlineSyntax() : super(r'\$[^$\n]+\$', startCharacter: 0x24); // $

  @override
  bool onMatch(InlineParser parser, Match match) {
    final raw = match.group(0)!;
    final latex = raw.substring(1, raw.length - 1).trim();
    if (latex.isEmpty) return false;

    parser.addNode(Element('math-inline', [Element.text('code', latex)]));
    return true;
  }
}
