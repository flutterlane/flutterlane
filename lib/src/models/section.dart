import 'package:flutter/material.dart';
import 'pane.dart';
import '../utils/id.dart';

/// A vertical group panel within a Swimlane.
///
/// Sections stack vertically within a single Swimlane, each containing
/// multiple Panes as tabs. Sections support collapse/expand, resize,
/// and vertical drag reorder.
class Section {
  /// Unique section identifier.
  final String sectionId;

  /// Display title for the section.
  String title;

  /// Optional icon data for the section header.
  IconData? icon;

  /// Whether the section content is expanded (visible).
  bool isExpanded;

  /// Whether this section exposes its collapse control and add-pane action.
  final bool canToggle;
  final bool canAddPane;

  /// Flex factor for vertical sizing within the Swimlane.
  /// null means auto-proportional distribution.
  double? flex;

  /// List of panes (tabs) within this section.
  List<Pane> panes;

  /// ID of the currently active (selected) pane tab.
  String? activePaneId;

  Section({
    String? sectionId,
    this.title = '',
    this.icon,
    this.isExpanded = true,
    this.canToggle = true,
    this.canAddPane = true,
    this.flex,
    List<Pane>? panes,
    this.activePaneId,
  })  : sectionId = sectionId ?? generateId(),
        panes = panes ?? [],
        assert(
          panes == null || panes.every((p) => p.paneId.isNotEmpty),
          'All panes must have valid IDs',
        );

  /// Whether this section is a placeholder (no real panes).
  bool get isPlaceholder => panes.isEmpty;

  /// The currently active pane, or null if none.
  Pane? get activePane =>
      panes.where((p) => p.paneId == activePaneId).firstOrNull;

  /// Selects a pane as active.
  void activatePane(String paneId) {
    assert(panes.any((p) => p.paneId == paneId));
    activePaneId = paneId;
  }

  /// Removes a pane by ID, auto-selecting the next one if needed.
  Pane? removePane(String paneId) {
    final index = panes.indexWhere((p) => p.paneId == paneId);
    if (index == -1) return null;
    final removed = panes.removeAt(index);
    if (activePaneId == paneId) {
      activePaneId = panes.isNotEmpty
          ? panes[index.clamp(0, panes.length - 1)].paneId
          : null;
    }
    return removed;
  }

  /// Adds a pane, auto-activating it if it's the first.
  void addPane(Pane pane) {
    panes.add(pane);
    if (activePaneId == null) {
      activePaneId = pane.paneId;
    }
  }

  /// Creates a blank placeholder section (no panes).
  factory Section.placeholder() => Section(
        title: '',
        panes: [],
        isExpanded: true,
      );

  Map<String, dynamic> toJson() => {
        'sectionId': sectionId,
        'title': title,
        'iconCodePoint': icon?.codePoint,
        'iconFontFamily': icon?.fontFamily,
        'isExpanded': isExpanded,
        'canToggle': canToggle,
        'canAddPane': canAddPane,
        'flex': flex,
        'panes': panes.map((p) => p.toJson()).toList(),
        'activePaneId': activePaneId,
      };

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionId: json['sectionId'] as String?,
      title: json['title'] as String? ?? '',
      icon: json['iconCodePoint'] != null
          ? IconData(
              json['iconCodePoint'] as int,
              fontFamily: json['iconFontFamily'] as String?,
            )
          : null,
      isExpanded: json['isExpanded'] as bool? ?? true,
      canToggle: json['canToggle'] as bool? ?? true,
      canAddPane: json['canAddPane'] as bool? ?? true,
      flex: (json['flex'] as num?)?.toDouble(),
      panes: (json['panes'] as List?)
              ?.map((e) => Pane.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activePaneId: json['activePaneId'] as String?,
    );
  }
}
