import 'package:flutter/material.dart';

import '../markdown_theme.dart';

/// Builds a placeholder widget for Mermaid diagrams.
///
/// Since Mermaid rendering in pure Dart is still maturing, this builder
/// shows the diagram source code with a placeholder message.
/// Can be upgraded to use `flutter_mermaid` or `merman` (Rust FFI) later.
class MermaidBuilder {
  /// Build a Mermaid diagram widget.
  ///
  /// [source] is the raw Mermaid diagram source code.
  /// [theme] provides colors for the placeholder styling.
  static Widget build({
    required String source,
    required MarkdownThemeData theme,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.codeBlockBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.mermaidBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_tree,
                size: 16,
                color: theme.mermaidIconColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Mermaid Diagram',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.mermaidTextColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.mermaidBadgeBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PREVIEW',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: theme.mermaidBadgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              source,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: theme.codeBlockTextColor,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mermaid rendering coming soon. Source shown above.',
            style: TextStyle(
              fontSize: 11,
              color: theme.mermaidTextColor.withAlpha(150),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
