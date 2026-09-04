import 'package:flutter/material.dart';

import '../../models/section.dart';
import '../../models/pane.dart';
import '../../registry/flutter_lane_registry.dart';
import '../../theme/flutter_lane_theme.dart';
import '../../interactions/drag/drag_target_info.dart';
import '../pane/pane_widget.dart';
import '../tab_bar/section_tab_bar.dart';

/// Renders a Section: header/tab-bar + scrollable pane content area.
///
/// Tabs are [Draggable] — they can be dragged to reorder within the same
/// section or dropped onto another section's tab bar to migrate the pane.
/// The tab bar itself is a [DragTarget<DragSource>] that accepts pane drops.
class SectionWidget extends StatelessWidget {
  final Section section;
  final String swimlaneId;
  final FlutterLaneRegistry registry;
  final VoidCallback? onAddPane;
  final void Function(String sectionId, String viewTypeId)? onAddViewSelect;
  final VoidCallback? onToggleSectionExpand;
  final void Function(String paneId)? onTabTap;
  final void Function(String paneId)? onClosePane;

  /// Called when a pane is dropped onto this section's tab bar.
  final void Function(DragSource source, int? dropIndex)? onPaneDrop;
  final void Function(DragSource source, SectionDropPosition position)? onSectionDrop;

  /// Called when a section header is dragged.
  final void Function(DragSource source)? onSectionDragStarted;

  final Widget? tabBarTrailing;

  const SectionWidget({
    super.key,
    required this.section,
    required this.swimlaneId,
    required this.registry,
    this.onAddPane,
    this.onAddViewSelect,
    this.onToggleSectionExpand,
    this.onTabTap,
    this.onClosePane,
    this.onPaneDrop,
    this.onSectionDrop,
    this.onSectionDragStarted,
    this.tabBarTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);
    return Column(
      children: [
        _SectionDragTarget(
          section: section,
          swimlaneId: swimlaneId,
          theme: theme,
          registry: registry,
          onAddPane: onAddPane,
          onAddViewSelect: onAddViewSelect,
          onToggleSectionExpand: onToggleSectionExpand,
          onTabTap: onTabTap,
          onClosePane: onClosePane,
          onPaneDrop: onPaneDrop,
          onSectionDrop: onSectionDrop,
          onSectionDragStarted: onSectionDragStarted,
          trailing: tabBarTrailing,
        ),
        if (section.isExpanded) ...[
          Expanded(
            child: section.activePane != null
                ? PaneWidget(
                    pane: section.activePane!,
                    registry: registry,
                  )
                : _EmptyContent(theme),
          ),
        ],
      ],
    );
  }
}

/// The tab bar, wrapped in a DragTarget that accepts pane drops.
class _SectionDragTarget extends StatelessWidget {
  final Section section;
  final String swimlaneId;
  final FlutterLaneThemeData theme;
  final FlutterLaneRegistry registry;
  final VoidCallback? onAddPane;
  final void Function(String sectionId, String viewTypeId)? onAddViewSelect;
  final VoidCallback? onToggleSectionExpand;
  final void Function(String paneId)? onTabTap;
  final void Function(String paneId)? onClosePane;
  final void Function(DragSource source, int? dropIndex)? onPaneDrop;
  final void Function(DragSource source, SectionDropPosition position)? onSectionDrop;
  final void Function(DragSource source)? onSectionDragStarted;
  final Widget? trailing;

  const _SectionDragTarget({
    required this.section,
    required this.swimlaneId,
    required this.theme,
    required this.registry,
    this.onAddPane,
    this.onAddViewSelect,
    this.onToggleSectionExpand,
    this.onTabTap,
    this.onClosePane,
    this.onPaneDrop,
    this.onSectionDrop,
    this.onSectionDragStarted,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isActivityBar = section.panes.length == 1 &&
        section.panes.first.viewInstance.viewTypeId == 'activitybar';
    return DragTarget<DragSource>(
      key: ValueKey('section-drop-${section.sectionId}'),
      onWillAcceptWithDetails: (details) {
        // Accept pane drops from any source (including other sections/swimlanes).
        return details.data.isPaneDrag || details.data.isSectionDrag;
      },
      onAcceptWithDetails: (details) {
        final source = details.data;
        if (source.isPaneDrag) {
          onPaneDrop?.call(source, null);
        } else if (source.isSectionDrag) {
          onSectionDrop?.call(source, SectionDropPosition.bottom);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          height: 32,
          decoration: BoxDecoration(
            color: isHovering
                ? theme.hoverZoneActiveColor
                : theme.tabBarBackground,
            border: Border(
              bottom: BorderSide(color: theme.tabBorderColor, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SectionTabBar(
                  sectionTitle: section.title,
                  sectionIcon: section.icon,
                  isExpanded: section.isExpanded,
                  canToggle: section.canToggle && !isActivityBar,
                  canAddPane: section.canAddPane && !isActivityBar,
                  panes: section.panes,
                  activePaneId: section.activePaneId,
                  sectionId: section.sectionId,
                  swimlaneId: swimlaneId,
                  registry: registry,
                  onToggleSectionExpand: onToggleSectionExpand,
                  onSelectPane: onTabTap,
                  onClosePane: onClosePane,
                  onPaneDroppedAt: onPaneDrop,
                    onSectionDrop: (source) =>
                      onSectionDrop?.call(source, SectionDropPosition.bottom),
                    onAddViewSelect: onAddViewSelect,
                    onAddPane: onAddPane,
                  onSectionDragStarted: () => onSectionDragStarted?.call(
                    DragSource.section(
                      fromSwimlaneId: swimlaneId,
                      sectionId: section.sectionId,
                    ),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
              const SizedBox(width: 4),
            ],
          ),
        );
      },
    );
  }
}

/// Draggable section handle — drag the header to move an entire section.
class _SectionDragHandle extends StatefulWidget {
  final Section section;
  final String swimlaneId;
  final FlutterLaneThemeData theme;

  const _SectionDragHandle({
    required this.section,
    required this.swimlaneId,
    required this.theme,
  });

  @override
  State<_SectionDragHandle> createState() => _SectionDragHandleState();
}

class _SectionDragHandleState extends State<_SectionDragHandle> {
  @override
  Widget build(BuildContext context) {
    return Draggable<DragSource>(
      data: DragSource.section(
        fromSwimlaneId: widget.swimlaneId,
        sectionId: widget.section.sectionId,
      ),
      onDragStarted: () {},
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.theme.dragPreviewColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.section.title.isNotEmpty
                ? widget.section.title
                : 'Section',
            style: TextStyle(
              fontSize: 11,
              color: widget.theme.sectionHeaderTextColor,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildLabel(),
      ),
      child: _buildLabel(),
    );
  }

  Widget _buildLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.section.icon ?? Icons.drag_indicator,
            size: 12,
            color: widget.theme.sectionHeaderTextColor,
          ),
          const SizedBox(width: 2),
          Text(
            widget.section.title.isNotEmpty
                ? widget.section.title
                : 'Section',
            style: TextStyle(
              fontSize: 10,
              color: widget.theme.sectionHeaderTextColor,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

/// A single tab, wrapped in [Draggable] so it can be moved.
class DraggableTab extends StatelessWidget {
  final Pane pane;
  final String sectionId;
  final String swimlaneId;
  final bool isActive;
  final FlutterLaneThemeData theme;
  final FlutterLaneRegistry registry;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final void Function(DragSource source, int dropIndex) onPaneDroppedAt;

  const DraggableTab({
    super.key,
    required this.pane,
    required this.sectionId,
    required this.swimlaneId,
    required this.isActive,
    required this.theme,
    required this.registry,
    required this.onTap,
    required this.onClose,
    required this.onPaneDroppedAt,
  });

  @override
  Widget build(BuildContext context) {
    final meta = registry.getPaneView(pane.viewInstance.viewTypeId);
    final label = meta?.viewDisplayName ?? pane.viewInstance.viewTypeId;

    return Draggable<DragSource>(
      data: DragSource.pane(
        fromSwimlaneId: swimlaneId,
        fromSectionId: sectionId,
        paneId: pane.paneId,
      ),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: theme.dragPreviewColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (meta?.icon != null) ...[
                Icon(meta!.icon, size: 12, color: theme.tabActiveTextColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.tabActiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTab(label, meta?.icon),
      ),
      child: _buildTab(label, meta?.icon),
    );
  }

  Widget _buildTab(String label, IconData? icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.tabActiveBackground : Colors.transparent,
          border: Border(
            right: BorderSide(color: theme.tabBorderColor, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 12,
                  color: isActive
                      ? theme.tabActiveTextColor
                      : theme.tabInactiveTextColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive
                    ? theme.tabActiveTextColor
                    : theme.tabInactiveTextColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onClose,
              child: Icon(
                Icons.close,
                size: 10,
                color: isActive
                    ? theme.tabActiveTextColor
                    : theme.tabInactiveTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  final FlutterLaneThemeData theme;
  const _EmptyContent(this.theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.paneContentBackground,
      alignment: Alignment.center,
      child: Text(
        'No views open',
        style: TextStyle(color: theme.tabInactiveTextColor, fontSize: 12),
      ),
    );
  }
}
