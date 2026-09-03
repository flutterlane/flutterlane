import 'package:flutter/material.dart';

/// Describes what is being dragged.
///
/// Used as the data payload for [Draggable] and accepted by [DragTarget].
/// The type field determines which drag operations are allowed.
enum DragType { pane, section, swimlane }

/// Data payload carried by every Draggable in the layout engine.
@immutable
class DragSource {
  final DragType type;
  final String swimlaneId;
  final String? sectionId;
  final String? paneId;

  const DragSource({
    required this.type,
    required this.swimlaneId,
    this.sectionId,
    this.paneId,
  });

  /// Convenience: create a pane-level drag source.
  const DragSource.pane({
    required String fromSwimlaneId,
    required String fromSectionId,
    required this.paneId,
  })  : type = DragType.pane,
        swimlaneId = fromSwimlaneId,
        sectionId = fromSectionId;

  /// Convenience: create a section-level drag source.
  const DragSource.section({
    required String fromSwimlaneId,
    required this.sectionId,
  })  : type = DragType.section,
        swimlaneId = fromSwimlaneId,
        paneId = null;

  /// Convenience: create a swimlane-level drag source.
  const DragSource.swimlane({required String fromSwimlaneId})
      : type = DragType.swimlane,
        swimlaneId = fromSwimlaneId,
        sectionId = null,
        paneId = null;

  bool get isPaneDrag => type == DragType.pane;
  bool get isSectionDrag => type == DragType.section;
  bool get isSwimlaneDrag => type == DragType.swimlane;
}

/// Where a section lands within a target swimlane.
enum SectionDropPosition { top, bottom }

/// Describes where a drag item should land.
@immutable
class DropTarget {
  final String swimlaneId;
  final String? sectionId;
  final int? index;
  final SectionDropPosition? sectionPosition;

  const DropTarget({
    required this.swimlaneId,
    this.sectionId,
    this.index,
    this.sectionPosition,
  });
}
