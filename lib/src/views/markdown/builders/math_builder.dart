import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../markdown_theme.dart';

/// Builds LaTeX math widgets using flutter_math_fork.
///
/// Renders KaTeX-compatible LaTeX expressions as native Flutter widgets.
class MathBuilder {
  /// Build an inline math widget.
  static Widget buildInline({
    required String latex,
    required MarkdownThemeData theme,
  }) {
    return Math.tex(
      latex,
      textStyle: TextStyle(
        fontSize: 14,
        color: theme.textColor,
      ),
      onErrorFallback: (FlutterMathException error) => _buildError(error.message, theme),
    );
  }

  /// Build a display (block) math widget.
  static Widget buildBlock({
    required String latex,
    required MarkdownThemeData theme,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.mathBlockBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.mathBlockBorderColor,
          width: 1,
        ),
      ),
      child: Center(
        child: Math.tex(
          latex,
          textStyle: TextStyle(
            fontSize: 18,
            color: theme.textColor,
          ),
          mathStyle: MathStyle.display,
          onErrorFallback: (FlutterMathException error) => _buildError(error.message, theme),
        ),
      ),
    );
  }

  static Widget _buildError(String error, MarkdownThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 14, color: Colors.red),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'Math error: $error',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
