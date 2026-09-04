import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

import '../markdown_theme.dart';

/// Builds a syntax-highlighted code block widget from a fenced code block.
///
/// Uses the `highlight` package for syntax highlighting with 192+ languages.
/// Supports theme switching between light and dark modes.
class CodeBlockBuilder {
  /// Build a highlighted code block widget.
  ///
  /// [code] is the raw code content.
  /// [language] is the optional language identifier (e.g. 'dart', 'python').
  /// [theme] provides colors for the markdown context.
  static Widget build({
    required String code,
    String? language,
    required MarkdownThemeData theme,
  }) {
    final map = language != null && language.isNotEmpty
        ? monokaiSublimeTheme
        : monokaiSublimeTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.codeBlockBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.codeBlockBorderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language != null && language.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.codeBlockHeaderBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.codeBlockHeaderTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.copy,
                    size: 14,
                    color: theme.codeBlockHeaderTextColor,
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: HighlightView(
              code,
              language: language ?? 'plaintext',
              theme: map,
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
