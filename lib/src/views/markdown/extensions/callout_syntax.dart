import 'package:markdown/markdown.dart';

/// Supported callout types for admonition blocks.
enum CalloutType {
  note,
  tip,
  important,
  warning,
  caution;

  String get emoji {
    switch (this) {
      case CalloutType.note:
        return '📝';
      case CalloutType.tip:
        return '💡';
      case CalloutType.important:
        return '❗';
      case CalloutType.warning:
        return '⚠️';
      case CalloutType.caution:
        return '🛑';
    }
  }

  static CalloutType fromString(String value) {
    for (final type in CalloutType.values) {
      if (type.name.toUpperCase() == value.toUpperCase()) return type;
    }
    return CalloutType.note;
  }
}

/// Matches GitHub-style admonition/callout blocks.
///
/// Syntax:
/// ```markdown
/// > [!NOTE]
/// > This is a note.
/// ```
class CalloutSyntax extends BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^>\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*$');

  const CalloutSyntax();

  @override
  Node? parse(BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content);
    if (match == null) return null;

    final typeStr = match.group(1)!;
    final calloutType = CalloutType.fromString(typeStr);

    final contentLines = <String>[];
    parser.advance();

    while (!parser.isDone) {
      final current = parser.current;
      final content = current.content;

      if (content.startsWith('>')) {
        final text = content.startsWith('> ') ? content.substring(2) : content.substring(1);
        contentLines.add(text);
        parser.advance();
      } else if (content.trim().isEmpty) {
        parser.advance();
        if (parser.isDone || !parser.current.content.startsWith('>')) {
          break;
        }
      } else {
        break;
      }
    }

    return Element('callout', [
      Element.text('code', '${calloutType.name}\n${contentLines.join('\n').trim()}'),
    ]);
  }
}
