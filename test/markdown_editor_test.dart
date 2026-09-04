import 'package:flutter_test/flutter_test.dart';
import 'package:flutterlane/flutterlane.dart';

void main() {
  group('MarkdownController', () {
    test('initializes with empty text', () {
      final controller = MarkdownController();
      expect(controller.text, '');
    });

    test('initializes with custom text', () {
      final controller = MarkdownController(initialText: '# Hello');
      expect(controller.text, '# Hello');
    });

    test('set text notifies listeners', () {
      final controller = MarkdownController();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.text = 'new content';
      expect(notified, true);
      expect(controller.text, 'new content');
    });

    test('set text with same value does not notify', () {
      final controller = MarkdownController(initialText: 'same');
      var notified = false;
      controller.addListener(() => notified = true);

      controller.text = 'same';
      expect(notified, false);
    });

    test('append adds text', () {
      final controller = MarkdownController(initialText: 'Hello');
      controller.append(' World');
      expect(controller.text, 'Hello World');
    });

    test('append notifies listeners', () {
      final controller = MarkdownController(initialText: 'A');
      var notified = false;
      controller.addListener(() => notified = true);

      controller.append('B');
      expect(notified, true);
    });

    test('replaceRange replaces correct portion', () {
      final controller = MarkdownController(initialText: 'Hello World');
      controller.replaceRange(6, 11, 'Dart');
      expect(controller.text, 'Hello Dart');
    });

    test('replaceRange notifies listeners', () {
      final controller = MarkdownController(initialText: 'ABC');
      var notified = false;
      controller.addListener(() => notified = true);

      controller.replaceRange(1, 2, 'X');
      expect(notified, true);
      expect(controller.text, 'AXC');
    });
  });

  group('MarkdownDisplayMode', () {
    test('has split and tabbed values', () {
      expect(MarkdownDisplayMode.split, isNotNull);
      expect(MarkdownDisplayMode.tabbed, isNotNull);
    });
  });
}
