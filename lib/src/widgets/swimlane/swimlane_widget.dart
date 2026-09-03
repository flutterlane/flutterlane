import 'package:flutter/material.dart';

import '../../models/swimlane.dart';
import '../../registry/flutter_lane_registry.dart';
import '../../theme/flutter_lane_theme.dart';
import '../../interactions/drag/drag_target_info.dart';
import '../section/section_widget.dart';

/// Renders a single Swimlane: vertical stack of sections with resize handles.
///
/// The swimlane body is a [DragTarget<DragSource>] that accepts section-level
/// drops (moving a section from another swimlane). The bottom of each swimlane
/// has a hover hot zone for adding new sections. Between sections, a resize
/// handle allows vertical resizing via drag.
class SwimlaneWidget extends StatelessWidget {
  final Swimlane swimlane;
  final FlutterLaneRegistry registry;
  final VoidCallback? onAddSection;
  final VoidCallback? onCloseSwimlane;
  final void Function(String paneId)? onTabTap;
  final void Function(String paneId)? onClosePane;
  final VoidCallback? onAddPane;
  final ValueChanged<String>? onAddViewSelect;
  final void Function(String sectionId)? onToggleSection;

  /// Called when a section is dropped onto this swimlane.
  final void Function(DragSource source, SectionDropPosition position)?
      onSectionDrop;

  /// Called when a pane is dropped onto a section in this swimlane.
  final void Function(
      String targetSectionId, DragSource source, int? dropIndex)? onPaneDrop;

  /// Called when a section resize handle is dragged. [deltaDy] is the vertical
  /// pixel delta; the caller should convert it to a flex change.
  final void Function(String sectionId, double deltaDy)? onResizeSection;

  const SwimlaneWidget({
    super.key,
    required this.swimlane,
    required this.registry,
    this.onAddSection,
    this.onCloseSwimlane,
    this.onTabTap,
    this.onClosePane,
    this.onAddPane,
    this.onAddViewSelect,
    this.onToggleSection,
    this.onSectionDrop,
    this.onPaneDrop,
    this.onResizeSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);

    return DragTarget<DragSource>(
      onWillAcceptWithDetails: (details) {
        return details.data.isSectionDrag &&
            details.data.swimlaneId != swimlane.id;
      },
      onAcceptWithDetails: (details) {
        onSectionDrop?.call(
          details.data,
          SectionDropPosition.bottom,
        );
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: isHovering
                ? theme.hoverZoneActiveColor
                : theme.swimlaneBackground,
            border: Border(
              right: BorderSide(color: theme.swimlaneDivider, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: _SectionStack(
                  swimlane: swimlane,
                  registry: registry,
                  onTabTap: onTabTap,
                  onClosePane: onClosePane,
                  onAddPane: onAddPane,
                  onAddViewSelect: onAddViewSelect,
                  onToggleSection: onToggleSection,
                  onPaneDrop: onPaneDrop,
                  onSectionDrop: onSectionDrop,
                  onResizeSection: onResizeSection,
                  onCloseSwimlane: onCloseSwimlane,
                ),
              ),
              if (onAddSection != null)
                _AddSectionHotZone(theme: theme, onTap: onAddSection!),
            ],
          ),
        );
      },
    );
  }
}

class _SwimlaneCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SwimlaneCloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('swimlane-close'),
      tooltip: 'Close swimlane',
      icon: const Icon(Icons.close, size: 13),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      onPressed: onTap,
    );
  }
}

class _SectionStack extends StatelessWidget {
  final Swimlane swimlane;
  final FlutterLaneRegistry registry;
  final void Function(String paneId)? onTabTap;
  final void Function(String paneId)? onClosePane;
  final VoidCallback? onAddPane;
  final ValueChanged<String>? onAddViewSelect;
  final void Function(String sectionId)? onToggleSection;
  final void Function(
      String targetSectionId, DragSource source, int? dropIndex)? onPaneDrop;
  final void Function(DragSource source, SectionDropPosition position)?
      onSectionDrop;
  final void Function(String sectionId, double deltaDy)? onResizeSection;
  final VoidCallback? onCloseSwimlane;

  const _SectionStack({
    required this.swimlane,
    required this.registry,
    this.onTabTap,
    this.onClosePane,
    this.onAddPane,
    this.onAddViewSelect,
    this.onToggleSection,
    this.onPaneDrop,
    this.onSectionDrop,
    this.onResizeSection,
    this.onCloseSwimlane,
  });

  @override
  Widget build(BuildContext context) {
    if (swimlane.sections.isEmpty) {
      return const SizedBox.shrink();
    }

    if (swimlane.sections.length == 1) {
      return SectionWidget(
        section: swimlane.sections.first,
        swimlaneId: swimlane.id,
        registry: registry,
        onAddPane: onAddPane,
        onAddViewSelect: onAddViewSelect,
        onToggleSectionExpand: onToggleSection == null
            ? null
            : () => onToggleSection!(swimlane.sections.first.sectionId),
        onTabTap: onTabTap,
        onClosePane: onClosePane,
        tabBarTrailing: onCloseSwimlane == null
            ? null
            : _SwimlaneCloseButton(onTap: onCloseSwimlane!),
        onPaneDrop: (source, dropIndex) {
          onPaneDrop?.call(
            swimlane.sections.first.sectionId,
            source,
            dropIndex,
          );
        },
        onSectionDrop: onSectionDrop,
      );
    }

    final totalFlex = swimlane.sections.fold<double>(
      0,
      (sum, s) => sum + (s.flex ?? 1.0),
    );

    return Column(
      children: [
        for (var i = 0; i < swimlane.sections.length; i++) ...[
          Expanded(
            flex:
                ((swimlane.sections[i].flex ?? 1.0) / totalFlex * 1000).round(),
            child: SectionWidget(
              section: swimlane.sections[i],
              swimlaneId: swimlane.id,
              registry: registry,
              onAddPane: onAddPane,
              onAddViewSelect: onAddViewSelect,
              onToggleSectionExpand: onToggleSection == null
                  ? null
                  : () => onToggleSection!(swimlane.sections[i].sectionId),
              onTabTap: onTabTap,
              onClosePane: onClosePane,
              tabBarTrailing: i == 0 && onCloseSwimlane != null
                  ? _SwimlaneCloseButton(onTap: onCloseSwimlane!)
                  : null,
              onPaneDrop: (source, dropIndex) {
                onPaneDrop?.call(
                  swimlane.sections[i].sectionId,
                  source,
                  dropIndex,
                );
              },
              onSectionDrop: onSectionDrop,
            ),
          ),
          if (i < swimlane.sections.length - 1)
            _SectionResizeHandle(
              theme: FlutterLaneTheme.of(context),
              topSectionId: swimlane.sections[i].sectionId,
              bottomSectionId: swimlane.sections[i + 1].sectionId,
              totalFlex: totalFlex,
              totalHeight: 1.0, // Normalized; actual height comes from layout
              onResize: onResizeSection,
            ),
        ],
      ],
    );
  }
}

/// A draggable resize handle between two sections.
///
/// Dragging up decreases the top section's flex and increases the bottom's.
/// Dragging down does the opposite.
class _SectionResizeHandle extends StatefulWidget {
  final FlutterLaneThemeData theme;
  final String topSectionId;
  final String bottomSectionId;
  final double totalFlex;
  final double totalHeight;
  final void Function(String sectionId, double deltaDy)? onResize;

  const _SectionResizeHandle({
    required this.theme,
    required this.topSectionId,
    required this.bottomSectionId,
    required this.totalFlex,
    required this.totalHeight,
    this.onResize,
  });

  @override
  State<_SectionResizeHandle> createState() => _SectionResizeHandleState();
}

class _SectionResizeHandleState extends State<_SectionResizeHandle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: ValueKey('section-resize-${widget.topSectionId}'),
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          // Convert pixel delta to flex units.
          // Each section gets flex proportional to its share of total flex.
          // A 1px drag means approximately 1/availableHeight of total flex.
          // We use a sensitivity factor so the resize feels natural.
          final delta = details.delta.dy;
          const sensitivity = 0.005; // flex units per pixel
          widget.onResize?.call(widget.topSectionId, -delta * sensitivity);
        },
        child: Container(
          height: 4,
          color: _isHovered
              ? widget.theme.resizeHandleHoverColor
              : widget.theme.resizeHandleColor,
        ),
      ),
    );
  }
}

class _AddSectionHotZone extends StatefulWidget {
  final FlutterLaneThemeData theme;
  final VoidCallback onTap;
  const _AddSectionHotZone({required this.theme, required this.onTap});

  @override
  State<_AddSectionHotZone> createState() => _AddSectionHotZoneState();
}

class _AddSectionHotZoneState extends State<_AddSectionHotZone> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: _isHovered ? 28 : 4,
          color: _isHovered
              ? widget.theme.hoverZoneActiveColor
              : widget.theme.hoverZoneColor,
          alignment: Alignment.center,
          child: _isHovered
              ? const Icon(Icons.add, size: 14, color: Colors.white70)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
