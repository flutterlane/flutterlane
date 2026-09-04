import 'package:flutter/material.dart';

import '../core/flutter_lane_manager.dart';
import '../interactions/drag/drag_target_info.dart';
import '../interactions/hover/add_swimlane_hot_zone.dart';
import '../interactions/resize/resize_handle.dart';
import '../models/layout_state.dart';
import '../models/pane.dart';
import '../models/section.dart';
import '../models/swimlane.dart';
import '../models/view_instance.dart';
import '../theme/flutter_lane_theme.dart';
import '../utils/id.dart';
import 'swimlane/swimlane_widget.dart';

/// Top-level FlutterLane workbench: horizontally scrollable swimlanes.
class FlutterLaneWorkbench extends StatelessWidget {
  final FlutterLaneManager manager;

  const FlutterLaneWorkbench({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) => FlutterLaneTheme(
        data: manager.currentTheme,
        child: _WorkbenchBody(
          manager: manager,
          activeLayout: manager.activeLayout,
        ),
      ),
    );
  }
}

class _WorkbenchBody extends StatelessWidget {
  final FlutterLaneManager manager;
  final LayoutState? activeLayout;

  const _WorkbenchBody({required this.manager, required this.activeLayout});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);
    final swimlanes = activeLayout?.swimlanes ?? <Swimlane>[];

    return Container(
      color: theme.swimlaneBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {


          return Stack(
            children: [
              Row(
                children: [
                  for (var index = 0; index < swimlanes.length; index++) ...[
                    if (index > 0)
                      ResizeHandle(
                        key: ValueKey('swimlane-resize-${swimlanes[index - 1].id}'),
                        isHorizontal: true,
                        disabled: swimlanes[index - 1].fixedWidth != null ||
                            swimlanes[index].fixedWidth != null,
                        onDrag: (delta) =>
                            manager.resizeSwimlane(swimlanes[index - 1].id, delta),
                      ),
                    _buildSwimlaneSlot(swimlanes[index], index),
                  ],
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                width: 16,
                height: constraints.maxHeight / 2,
                child: AddSwimlaneHotZone(
                  onAdd: () => manager.addSwimlane(
                    Swimlane(sections: [Section(title: 'New Section')]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwimlane(Swimlane swimlane, {VoidCallback? onCloseSwimlane}) {
    return SwimlaneWidget(
      swimlane: swimlane,
      registry: manager.registry,
      onCloseSwimlane: onCloseSwimlane,
      onAddSection: () => manager.addSectionToSwimlane(
        swimlane.id,
        Section(title: 'New Section'),
      ),
      onAddPane: () {
        final views = manager.registry.allPaneViews;
        if (views.isNotEmpty && swimlane.sections.isNotEmpty) {
          _addPane(swimlane, swimlane.sections.first.sectionId,
              views.first.viewTypeId);
        }
      },
      onAddViewSelect: (sectionId, viewTypeId) {
        _addPane(swimlane, sectionId, viewTypeId);
      },
      onToggleSection: (sectionId) =>
          manager.toggleSectionExpanded(swimlane.id, sectionId),
      onTabTap: (paneId) {
        final section = swimlane.sections
            .where(
                (section) => section.panes.any((pane) => pane.paneId == paneId))
            .firstOrNull;
        if (section != null) {
          manager.activatePane(swimlane.id, section.sectionId, paneId);
        }
      },
      onClosePane: (paneId) {
        final section = swimlane.sections
            .where(
                (section) => section.panes.any((pane) => pane.paneId == paneId))
            .firstOrNull;
        if (section != null) {
          manager.removePaneFromSection(swimlane.id, section.sectionId, paneId);
        }
      },
      onPaneDrop: (targetSectionId, source, dropIndex) {
        manager.movePane(
          fromSwimlaneId: source.swimlaneId,
          fromSectionId: source.sectionId!,
          toSwimlaneId: swimlane.id,
          toSectionId: targetSectionId,
          paneId: source.paneId!,
          toIndex: dropIndex,
        );
      },
      onSectionDrop: (source, position) => manager.moveSection(
        fromSwimlaneId: source.swimlaneId,
        toSwimlaneId: swimlane.id,
        sectionId: source.sectionId!,
        toIndex: position == SectionDropPosition.top ? 0 : null,
      ),
      onResizeSection: (sectionId, deltaDy) =>
          manager.resizeSection(swimlane.id, sectionId, deltaDy),
    );
  }

  void _addPane(Swimlane swimlane, String sectionId, String viewTypeId) {
    manager.addPaneToSection(
      swimlane.id,
      sectionId,
      Pane(
        paneId: generateId(),
        viewInstance: ViewInstance(viewTypeId: viewTypeId),
      ),
    );
  }

  Widget _buildSwimlaneSlot(Swimlane lane, int index) {
    final closeLane = lane.canClose && !_isActivityBar(lane)
        ? () => manager.removeSwimlane(lane.id)
        : null;
    final content = DragTarget<DragSource>(
      onWillAcceptWithDetails: (details) =>
          details.data.isSwimlaneDrag &&
          details.data.swimlaneId != lane.id,
      onAcceptWithDetails: (details) =>
          manager.moveSwimlane(details.data.swimlaneId, index),
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<DragSource>(
          data: DragSource.swimlane(fromSwimlaneId: lane.id),
          feedback: FlutterLaneTheme(
            data: manager.currentTheme,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 200,
                height: 80,
                child: _buildSwimlane(lane, onCloseSwimlane: closeLane),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: .35,
            child: _buildSwimlane(lane, onCloseSwimlane: closeLane),
          ),
          child: _buildSwimlane(lane, onCloseSwimlane: closeLane),
        );
      },
    );

    if (lane.fixedWidth != null) {
      return SizedBox(width: lane.fixedWidth!, child: content);
    }
    return Expanded(
      flex: ((lane.flex) * 1000).round(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: lane.minWidth),
        child: content,
      ),
    );
  }

  bool _isActivityBar(Swimlane swimlane) {
    return swimlane.sections.length == 1 &&
        swimlane.sections.first.panes.length == 1 &&
        swimlane.sections.first.panes.first.viewInstance.viewTypeId ==
            'activitybar';
  }
}

