import 'package:flutter/material.dart';

import '../markdown_theme.dart';

/// Builds GFM-style tables from parsed table data.
///
/// Renders tables with headers, alignment support, and alternating row colors.
class TableBuilder {
  /// Build a table widget from header and body data.
  ///
  /// [headers] is the list of column header strings.
  /// [alignments] is the list of column alignments (optional).
  /// [rows] is the list of row data (each row is a list of cell strings).
  /// [theme] provides colors for the table styling.
  static Widget build({
    required List<String> headers,
    List<Alignment>? alignments,
    required List<List<String>> rows,
    required MarkdownThemeData theme,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.tableBorderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderRow(headers, alignments, theme),
          ...rows.asMap().entries.map((entry) {
            return _buildDataRow(
              entry.value,
              entry.key.isEven,
              alignments,
              theme,
            );
          }),
        ],
      ),
    );
  }

  static Widget _buildHeaderRow(
    List<String> headers,
    List<Alignment>? alignments,
    MarkdownThemeData theme,
  ) {
    return Container(
      color: theme.tableHeaderBackground,
      child: Row(
        children: headers.asMap().entries.map((entry) {
          final index = entry.key;
          final header = entry.value;
          final alignment = alignments != null && index < alignments.length
              ? alignments[index]
              : Alignment.centerLeft;

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              alignment: alignment,
              decoration: BoxDecoration(
                border: index < headers.length - 1
                    ? Border(
                        right: BorderSide(
                          color: theme.tableBorderColor,
                          width: 1,
                        ),
                      )
                    : null,
              ),
              child: Text(
                header,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.tableHeaderTextColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static Widget _buildDataRow(
    List<String> cells,
    bool isEven,
    List<Alignment>? alignments,
    MarkdownThemeData theme,
  ) {
    return Container(
      color: isEven ? theme.tableRowEvenBackground : theme.tableRowOddBackground,
      child: Row(
        children: cells.asMap().entries.map((entry) {
          final index = entry.key;
          final cell = entry.value;
          final alignment = alignments != null && index < alignments.length
              ? alignments[index]
              : Alignment.centerLeft;

          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: alignment,
              decoration: BoxDecoration(
                border: index < cells.length - 1
                    ? Border(
                        right: BorderSide(
                          color: theme.tableBorderColor,
                          width: 1,
                        ),
                      )
                    : null,
              ),
              child: Text(
                cell,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.tableBodyTextColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
