import 'package:flutter/material.dart';

import '../../models/pane.dart';
import '../../registry/flutter_lane_registry.dart';
import '../../theme/flutter_lane_theme.dart';
import '../../interactions/drag/drag_target_info.dart';

/// VS Code-style tab strip for panes inside a [Section].
///
/// This is intentionally different from [WindowTabBar], which is the
/// Chrome-style top-level window tab strip. Section tabs stay compact and
/// expose section collapse, pane close, drag/drop, and view creation.
class SectionTabBar extends StatelessWidget {
  final String sectionTitle;
  final IconData? sectionIcon;
  final bool isExpanded;
  final bool canToggle;
  final bool canAddPane;
  final List<Pane> panes;
  final String? activePaneId;
  final String sectionId;
  final String swimlaneId;
  final FlutterLaneRegistry registry;
  final VoidCallback? onToggleSectionExpand;
  final ValueChanged<String>? onSelectPane;
  final ValueChanged<String>? onClosePane;
  final void Function(DragSource source, int dropIndex)? onPaneDroppedAt;
  final ValueChanged<String>? onAddViewSelect;
  final VoidCallback? onAddPane;
  final ValueChanged<DragSource>? onSectionDrop;
  final VoidCallback? onSectionDragStarted;

  const SectionTabBar({
    super.key,
    required this.sectionTitle,
    required this.isExpanded,
    this.canToggle = true,
    this.canAddPane = true,
    required this.panes,
    required this.activePaneId,
    required this.sectionId,
    required this.swimlaneId,
    required this.registry,
    this.sectionIcon,
    this.onToggleSectionExpand,
    this.onSelectPane,
    this.onClosePane,
    this.onPaneDroppedAt,
    this.onAddViewSelect,
    this.onAddPane,
    this.onSectionDrop,
    this.onSectionDragStarted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);
    final showPaneTabs = canAddPane || panes.length > 1;
    return DragTarget<DragSource>(
      onWillAcceptWithDetails: (details) => details.data.isSectionDrag,
      onAcceptWithDetails: (details) => onSectionDrop?.call(details.data),
      builder: (context, candidateData, rejectedData) => Container(
      height: 32,
      decoration: BoxDecoration(
        color: theme.tabBarBackground,
        border: Border(bottom: BorderSide(color: theme.tabBorderColor, width: .5)),
      ),
      child: Row(
        children: [
          if (canToggle)
            InkWell(
              onTap: onToggleSectionExpand,
              child: SizedBox(
                width: 30,
                height: 32,
                child: Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: theme.sectionHeaderTextColor,
                ),
            ),
          ),
          if (sectionTitle.isNotEmpty)
            Draggable<DragSource>(
              key: ValueKey('section-drag-$sectionId'),
              data: DragSource.section(
                fromSwimlaneId: swimlaneId,
                sectionId: sectionId,
              ),
              onDragStarted: onSectionDragStarted,
              feedback: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(sectionTitle, style: TextStyle(fontSize: 10, color: theme.sectionHeaderTextColor)),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(sectionIcon ?? Icons.drag_indicator, size: 12, color: theme.sectionHeaderTextColor),
                    const SizedBox(width: 2),
                    Text(sectionTitle, style: TextStyle(fontSize: 10, color: theme.sectionHeaderTextColor)),
                  ],
                ),
              ),
            ),
          Expanded(
            child: showPaneTabs
                ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: panes.length,
              itemBuilder: (context, index) {
                final pane = panes[index];
                final meta = registry.getPaneView(pane.viewInstance.viewTypeId);
                return _SectionPaneTab(
                  pane: pane,
                  label: meta?.viewDisplayName ?? pane.viewInstance.viewTypeId,
                  icon: meta?.icon,
                  isActive: pane.paneId == activePaneId,
                  theme: theme,
                  sectionId: sectionId,
                  swimlaneId: swimlaneId,
                  onTap: () => onSelectPane?.call(pane.paneId),
                  onClose: () => onClosePane?.call(pane.paneId),
                  onDropped: onPaneDroppedAt,
                );
              },
                )
              : const SizedBox.shrink(),
          ),
          if (canAddPane && onAddViewSelect != null)
            PopupMenuButton<String>(
              tooltip: 'Add view',
              icon: Icon(Icons.add, size: 15, color: theme.tabInactiveTextColor),
              padding: EdgeInsets.zero,
              onSelected: onAddViewSelect,
              itemBuilder: (context) => registry.allPaneViews
                  .map((view) => PopupMenuItem<String>(
                        value: view.viewTypeId,
                        child: Row(children: [
                          Icon(view.icon, size: 14),
                          const SizedBox(width: 8),
                          Text(view.viewDisplayName),
                        ]),
                      ))
                  .toList(),
            )
          else if (canAddPane && onAddPane != null)
            IconButton(
              tooltip: 'Add pane',
              icon: Icon(Icons.add, size: 15, color: theme.tabInactiveTextColor),
              padding: EdgeInsets.zero,
              onPressed: onAddPane,
            ),
          const SizedBox(width: 4),
        ],
      ),
      ),
    );
  }
}

class _SectionPaneTab extends StatelessWidget {
  final Pane pane;
  final String label;
  final IconData? icon;
  final bool isActive;
  final FlutterLaneThemeData theme;
  final String sectionId;
  final String swimlaneId;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final void Function(DragSource source, int dropIndex)? onDropped;

  const _SectionPaneTab({
    required this.pane,
    required this.label,
    required this.isActive,
    required this.theme,
    required this.sectionId,
    required this.swimlaneId,
    required this.onTap,
    required this.onClose,
    this.icon,
    this.onDropped,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<DragSource>(
      data: DragSource.pane(fromSwimlaneId: swimlaneId, fromSectionId: sectionId, paneId: pane.paneId),
      feedback: Material(
        color: Colors.transparent,
        child: _tabContent(),
      ),
      childWhenDragging: Opacity(opacity: .3, child: _tabContent()),
      child: DragTarget<DragSource>(
        onWillAcceptWithDetails: (details) => details.data.isPaneDrag,
        onAcceptWithDetails: (details) => onDropped?.call(details.data, 0),
        builder: (context, candidate, rejected) => _tabContent(),
      ),
    );
  }

  Widget _tabContent() {
    final foreground = isActive ? theme.tabActiveTextColor : theme.tabInactiveTextColor;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 88, maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.tabActiveBackground : Colors.transparent,
          border: Border(right: BorderSide(color: theme.tabBorderColor, width: .5)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 12, color: foreground), const SizedBox(width: 4)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: foreground))),
          const SizedBox(width: 5),
          InkWell(onTap: onClose, child: Icon(Icons.close, size: 11, color: foreground)),
        ]),
      ),
    );
  }
}
