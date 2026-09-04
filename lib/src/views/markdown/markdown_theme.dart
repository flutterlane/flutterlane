import 'package:flutter/material.dart';

/// Theme data for the Markdown renderer.
///
/// Provides consistent styling for all markdown elements including
/// text, code blocks, math, tables, callouts, and diagrams.
class MarkdownThemeData {
  final Color textColor;
  final Color headingColor;
  final Color linkColor;
  final Color codeBlockBackground;
  final Color codeBlockTextColor;
  final Color codeBlockBorderColor;
  final Color codeBlockHeaderBackground;
  final Color codeBlockHeaderTextColor;
  final Color mathBlockBackground;
  final Color mathBlockBorderColor;
  final Color tableHeaderBackground;
  final Color tableHeaderTextColor;
  final Color tableBodyTextColor;
  final Color tableBorderColor;
  final Color tableRowEvenBackground;
  final Color tableRowOddBackground;
  final Color calloutNoteBackground;
  final Color calloutNoteBorderColor;
  final Color calloutTipBackground;
  final Color calloutTipBorderColor;
  final Color calloutWarningBackground;
  final Color calloutWarningBorderColor;
  final Color calloutCautionBackground;
  final Color calloutCautionBorderColor;
  final Color calloutImportantBackground;
  final Color calloutImportantBorderColor;
  final Color calloutTextColor;
  final Color blockquoteBorderColor;
  final Color blockquoteTextColor;
  final Color hrColor;
  final Color listBulletColor;
  final Color mermaidBorderColor;
  final Color mermaidIconColor;
  final Color mermaidTextColor;
  final Color mermaidBadgeBackground;
  final Color mermaidBadgeTextColor;

  const MarkdownThemeData({
    required this.textColor,
    required this.headingColor,
    required this.linkColor,
    required this.codeBlockBackground,
    required this.codeBlockTextColor,
    required this.codeBlockBorderColor,
    required this.codeBlockHeaderBackground,
    required this.codeBlockHeaderTextColor,
    required this.mathBlockBackground,
    required this.mathBlockBorderColor,
    required this.tableHeaderBackground,
    required this.tableHeaderTextColor,
    required this.tableBodyTextColor,
    required this.tableBorderColor,
    required this.tableRowEvenBackground,
    required this.tableRowOddBackground,
    required this.calloutNoteBackground,
    required this.calloutNoteBorderColor,
    required this.calloutTipBackground,
    required this.calloutTipBorderColor,
    required this.calloutWarningBackground,
    required this.calloutWarningBorderColor,
    required this.calloutCautionBackground,
    required this.calloutCautionBorderColor,
    required this.calloutImportantBackground,
    required this.calloutImportantBorderColor,
    required this.calloutTextColor,
    required this.blockquoteBorderColor,
    required this.blockquoteTextColor,
    required this.hrColor,
    required this.listBulletColor,
    required this.mermaidBorderColor,
    required this.mermaidIconColor,
    required this.mermaidTextColor,
    required this.mermaidBadgeBackground,
    required this.mermaidBadgeTextColor,
  });

  /// Dark theme suitable for IDE-like interfaces.
  static const dark = MarkdownThemeData(
    textColor: Color(0xFFD4D4D4),
    headingColor: Color(0xFFFFFFFF),
    linkColor: Color(0xFF4FC1FF),
    codeBlockBackground: Color(0xFF1E1E1E),
    codeBlockTextColor: Color(0xFFD4D4D4),
    codeBlockBorderColor: Color(0xFF333333),
    codeBlockHeaderBackground: Color(0xFF2D2D2D),
    codeBlockHeaderTextColor: Color(0xFF999999),
    mathBlockBackground: Color(0xFF1A1A2E),
    mathBlockBorderColor: Color(0xFF333355),
    tableHeaderBackground: Color(0xFF2D2D2D),
    tableHeaderTextColor: Color(0xFFFFFFFF),
    tableBodyTextColor: Color(0xFFD4D4D4),
    tableBorderColor: Color(0xFF333333),
    tableRowEvenBackground: Color(0xFF252526),
    tableRowOddBackground: Color(0xFF1E1E1E),
    calloutNoteBackground: Color(0xFF1E3A5F),
    calloutNoteBorderColor: Color(0xFF4FC1FF),
    calloutTipBackground: Color(0xFF1E3D2A),
    calloutTipBorderColor: Color(0xFF4CAF50),
    calloutWarningBackground: Color(0xFF3D2E1A),
    calloutWarningBorderColor: Color(0xFFFFC107),
    calloutCautionBackground: Color(0xFF3D1A1A),
    calloutCautionBorderColor: Color(0xFFF44336),
    calloutImportantBackground: Color(0xFF2E1A3D),
    calloutImportantBorderColor: Color(0xFF9C27B0),
    calloutTextColor: Color(0xFFD4D4D4),
    blockquoteBorderColor: Color(0xFF4FC1FF),
    blockquoteTextColor: Color(0xFF999999),
    hrColor: Color(0xFF333333),
    listBulletColor: Color(0xFF4FC1FF),
    mermaidBorderColor: Color(0xFF333355),
    mermaidIconColor: Color(0xFF4FC1FF),
    mermaidTextColor: Color(0xFFD4D4D4),
    mermaidBadgeBackground: Color(0xFF333355),
    mermaidBadgeTextColor: Color(0xFF4FC1FF),
  );

  /// Light theme suitable for document viewing.
  static const light = MarkdownThemeData(
    textColor: Color(0xFF333333),
    headingColor: Color(0xFF111111),
    linkColor: Color(0xFF0366D6),
    codeBlockBackground: Color(0xFFF6F8FA),
    codeBlockTextColor: Color(0xFF24292E),
    codeBlockBorderColor: Color(0xFFE1E4E8),
    codeBlockHeaderBackground: Color(0xFFE1E4E8),
    codeBlockHeaderTextColor: Color(0xFF586069),
    mathBlockBackground: Color(0xFFF0F4FF),
    mathBlockBorderColor: Color(0xFFD0D7E3),
    tableHeaderBackground: Color(0xFFF6F8FA),
    tableHeaderTextColor: Color(0xFF24292E),
    tableBodyTextColor: Color(0xFF333333),
    tableBorderColor: Color(0xFFE1E4E8),
    tableRowEvenBackground: Color(0xFFFFFFFF),
    tableRowOddBackground: Color(0xFFF6F8FA),
    calloutNoteBackground: Color(0xFFE8F4FD),
    calloutNoteBorderColor: Color(0xFF0366D6),
    calloutTipBackground: Color(0xFFE8F5E9),
    calloutTipBorderColor: Color(0xFF4CAF50),
    calloutWarningBackground: Color(0xFFFFF8E1),
    calloutWarningBorderColor: Color(0xFFFFC107),
    calloutCautionBackground: Color(0xFFFFEBEE),
    calloutCautionBorderColor: Color(0xFFF44336),
    calloutImportantBackground: Color(0xFFF3E5F5),
    calloutImportantBorderColor: Color(0xFF9C27B0),
    calloutTextColor: Color(0xFF333333),
    blockquoteBorderColor: Color(0xFF0366D6),
    blockquoteTextColor: Color(0xFF586069),
    hrColor: Color(0xFFE1E4E8),
    listBulletColor: Color(0xFF0366D6),
    mermaidBorderColor: Color(0xFFE1E4E8),
    mermaidIconColor: Color(0xFF0366D6),
    mermaidTextColor: Color(0xFF333333),
    mermaidBadgeBackground: Color(0xFFE8F4FD),
    mermaidBadgeTextColor: Color(0xFF0366D6),
  );

  /// Create a theme from a brightness setting.
  factory MarkdownThemeData.fromBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}
