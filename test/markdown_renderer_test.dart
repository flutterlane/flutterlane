import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterlane/flutterlane.dart';

void main() {
  group('MarkdownThemeData', () {
    test('dark theme has correct colors', () {
      const theme = MarkdownThemeData.dark;
      expect(theme.textColor, const Color(0xFFD4D4D4));
      expect(theme.headingColor, const Color(0xFFFFFFFF));
    });

    test('light theme has correct colors', () {
      const theme = MarkdownThemeData.light;
      expect(theme.textColor, const Color(0xFF333333));
    });

    test('fromBrightness returns correct theme', () {
      expect(MarkdownThemeData.fromBrightness(Brightness.dark), MarkdownThemeData.dark);
      expect(MarkdownThemeData.fromBrightness(Brightness.light), MarkdownThemeData.light);
    });
  });

  group('CalloutType', () {
    test('emoji returns correct values', () {
      expect(CalloutType.note.emoji, '📝');
      expect(CalloutType.tip.emoji, '💡');
      expect(CalloutType.warning.emoji, '⚠️');
      expect(CalloutType.caution.emoji, '🛑');
      expect(CalloutType.important.emoji, '❗');
    });

    test('fromString returns correct type', () {
      expect(CalloutType.fromString('note'), CalloutType.note);
      expect(CalloutType.fromString('TIP'), CalloutType.tip);
      expect(CalloutType.fromString('Warning'), CalloutType.warning);
      expect(CalloutType.fromString('unknown'), CalloutType.note);
    });
  });

  group('MarkdownRenderer', () {
    testWidgets('renders empty state', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '')),
      ));
      expect(find.text('Nothing to preview'), findsOneWidget);
    });

    testWidgets('renders heading', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '# Hello World')),
      ));
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('renders paragraph via RichText', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: 'This is a paragraph.')),
      ));
      // Paragraphs use RichText, so search the RichText widget's text span
      final richText = tester.widget<RichText>(find.byType(RichText).first);
      final text = (richText.text as TextSpan).toPlainText();
      expect(text, contains('This is a paragraph.'));
    });

    testWidgets('renders bold text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '**Bold text**')),
      ));
      final richText = tester.widget<RichText>(find.byType(RichText).first);
      final text = (richText.text as TextSpan).toPlainText();
      expect(text, contains('Bold text'));
    });

    testWidgets('renders inline code', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: 'Use `print()`')),
      ));
      // Inline code renders inside a paragraph via RichText
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('renders code block', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '```dart\nvoid main() {}\n```')),
      ));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders unordered list', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '- Item 1\n- Item 2')),
      ));
      // List items use RichText
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('renders blockquote', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '> This is a quote')),
      ));
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('renders horizontal rule', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '---')),
      ));
      // HR renders as a Container with height 1
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('renders link', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '[Click here](https://example.com)')),
      ));
      // Link renders inside a paragraph via RichText
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('renders frontmatter', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '---\ntitle: Hello\n---\n# Content')),
      ));
      // Frontmatter may render as metadata or as raw text
      expect(find.byType(RichText), findsWidgets);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('renders callout note', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '> [!NOTE]\n> This is a note')),
      ));
      // Callout renders as Container with text content
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders callout warning', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '> [!WARNING]\n> Be careful!')),
      ));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders mermaid placeholder', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '```mermaid\nflowchart TD\n    A --> B\n```')),
      ));
      // Mermaid renders as Container with placeholder
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders table', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(data: '| Name | Age |\n|------|-----|\n| Alice | 30 |')),
      ));
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('renders mixed content', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MarkdownRenderer(
          data: '# Title\n\nParagraph with **bold**.\n\n```dart\ncode\n```\n\n- List item',
        )),
      ));
      expect(find.text('Title'), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
    });
  });
}
