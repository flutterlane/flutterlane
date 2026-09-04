import 'package:flutter/foundation.dart';

import '../models/layout_state.dart';
import '../models/swimlane.dart';
import '../models/section.dart';
import '../models/pane.dart';
import '../storage/layout_storage.dart';
import '../storage/storage_path.dart';
import '../theme/flutter_lane_theme.dart';
import '../theme/theme_manager.dart';
import '../registry/flutter_lane_registry.dart';

/// Central orchestrator for the FlutterLane layout engine.
///
/// Manages all layout snapshots, the active layout, theme, and registry.
/// This is the single source of truth consumed by the widget tree.
class FlutterLaneManager extends ChangeNotifier {
  final LayoutStorage _storage = LayoutStorage();
  final ThemeManager themeManager = ThemeManager();
  final FlutterLaneRegistry registry = FlutterLaneRegistry();

  /// All saved layout snapshots.
  List<LayoutState> _layouts = [];

  /// The currently active layout state.
  LayoutState? _activeLayout;
  Future<void> _persistQueue = Future<void>.value();

  List<LayoutState> get layouts => List.unmodifiable(_layouts);
  LayoutState? get activeLayout => _activeLayout;

  /// The current theme data (convenience getter).
  FlutterLaneThemeData get currentTheme => themeManager.currentTheme;

  /// ── Initialization ──

  /// Initializes the engine: storage paths, theme, and loads persisted layouts.
  Future<void> init() async {
    if (kIsWeb) {
      // Browser demos use an in-memory layout; native persistence is desktop-only.
      themeManager.addListener(() => notifyListeners());
      _layouts = [LayoutState.systemDefault()];
      _activeLayout = _layouts.first;
      _activeLayout!.isCurrentActive = true;
      notifyListeners();
      return;
    }
    await StoragePath.init();
    await themeManager.init();
    themeManager.addListener(() => notifyListeners());

    _layouts = await _storage.readAll();

    // Ensure at least the system-default layout exists.
    if (_layouts.isEmpty) {
      final defaults = LayoutState.systemDefault();
      _layouts.add(defaults);
    }

    // Activate the persisted active layout, or fall back to first.
    final activeId = await _storage.readActiveId();
    _activeLayout = _layouts.firstWhere(
      (l) => l.snapshotId == activeId,
      orElse: () {
        final first = _layouts.first;
        first.isCurrentActive = true;
        return first;
      },
    );
    _activeLayout!.isCurrentActive = true;

    notifyListeners();
  }

  // ── Layout CRUD ──

  /// Saves (covers) the current active layout state to disk.
  Future<void> _persist() {
    final next = _persistQueue.then((_) async {
      if (_activeLayout != null) _activeLayout!.touch();
      try {
        await _storage.writeAll(_layouts);
      } catch (_) {
        // Best-effort persistence; silently ignore when storage is unavailable.
      }
      notifyListeners();
    });
    _persistQueue = next;
    return next;
  }

  /// Persists the current layout immediately after external model setup.
  Future<void> save() => _persist();

  /// Loads a layout state directly into the manager (for testing or manual setup).
  @visibleForTesting
  void loadLayout(LayoutState layout) {
    _activeLayout = layout;
    if (!_layouts.any((l) => l.snapshotId == layout.snapshotId)) {
      _layouts.add(layout);
    }
    notifyListeners();
  }

  /// Returns the layout snapshot bound to [businessContext], if any.
  LayoutState? layoutForContext(String businessContext) {
    for (final l in _layouts) {
      if (l.businessContext == businessContext) return l;
    }
    return null;
  }

  /// Adds a fully-formed snapshot (e.g. a workspace layout) to the store
  /// and persists it. Does not change the active layout.
  Future<void> addLayoutSnapshot(LayoutState layout) async {
    if (_layouts.any((l) => l.snapshotId == layout.snapshotId)) return;
    _layouts.add(layout);
    await _persist();
  }

  /// Adds a new swimlane to the active layout.
  void addSwimlane(Swimlane swimlane, {int? index}) {
    _activeLayout?.addSwimlane(swimlane, index: index);
    _persist();
  }

  /// Removes a swimlane by ID from the active layout.
  Swimlane? removeSwimlane(String swimlaneId) {
    final removed = _activeLayout?.removeSwimlane(swimlaneId);
    _persist();
    return removed;
  }

  /// Moves a swimlane to a new position in the active layout.
  void moveSwimlane(String swimlaneId, int toIndex) {
    final layout = _activeLayout;
    if (layout == null) return;
    final fromIndex =
        layout.swimlanes.indexWhere((lane) => lane.id == swimlaneId);
    if (fromIndex < 0 || toIndex < 0 || toIndex >= layout.swimlanes.length) {
      return;
    }
    final lane = layout.swimlanes.removeAt(fromIndex);
    layout.swimlanes.insert(toIndex.clamp(0, layout.swimlanes.length), lane);
    _persist();
  }

  /// Adds a section to the specified swimlane.
  void addSectionToSwimlane(String swimlaneId, Section section, {int? index}) {
    final swimlane = _findSwimlane(swimlaneId);
    swimlane?.addSection(section, index: index);
    _persist();
  }

  /// Removes a section from a swimlane.
  Section? removeSectionFromSwimlane(String swimlaneId, String sectionId) {
    final swimlane = _findSwimlane(swimlaneId);
    final removed = swimlane?.removeSection(sectionId);
    _persist();
    return removed;
  }

  /// Adds a pane to a section.
  void addPaneToSection(
      String swimlaneId, String sectionId, Pane pane) {
    final section = _findSection(swimlaneId, sectionId);
    section?.addPane(pane);
    _persist();
  }

  /// Removes a pane from a section.
  Pane? removePaneFromSection(
      String swimlaneId, String sectionId, String paneId) {
    final section = _findSection(swimlaneId, sectionId);
    final removed = section?.removePane(paneId);
    _persist();
    return removed;
  }

  /// Activates a pane tab within a section.
  void activatePane(String swimlaneId, String sectionId, String paneId) {
    final section = _findSection(swimlaneId, sectionId);
    section?.activatePane(paneId);
    _persist();
  }

  /// Toggles the expanded/collapsed state of a section.
  void toggleSectionExpanded(String swimlaneId, String sectionId) {
    final section = _findSection(swimlaneId, sectionId);
    if (section != null) {
      section.isExpanded = !section.isExpanded;
      _persist();
    }
  }

  /// Updates swimlane flex (width ratio).
  void updateSwimlaneFlex(String swimlaneId, double newFlex) {
    final swimlane = _findSwimlane(swimlaneId);
    if (swimlane != null) {
      swimlane.flex = newFlex;
      _persist();
    }
  }

  /// Resizes a swimlane and its right neighbor by a horizontal drag delta.
  void resizeSwimlane(String swimlaneId, double deltaDx) {
    final layout = _activeLayout;
    if (layout == null) return;
    final index = layout.swimlanes.indexWhere((lane) => lane.id == swimlaneId);
    if (index < 0 || index >= layout.swimlanes.length - 1) return;

    final left = layout.swimlanes[index];
    final right = layout.swimlanes[index + 1];
    if (left.fixedWidth != null || right.fixedWidth != null) return;
    const sensitivity = 0.005;
    final change = deltaDx * sensitivity;
    final nextLeft = (left.flex + change).clamp(0.1, 100.0).toDouble();
    final nextRight = (right.flex - (nextLeft - left.flex))
        .clamp(0.1, 100.0)
        .toDouble();
    left.flex = nextLeft;
    right.flex = nextRight;
    _persist();
  }

  /// Updates section flex (height ratio).
  void updateSectionFlex(
      String swimlaneId, String sectionId, double newFlex) {
    final section = _findSection(swimlaneId, sectionId);
    if (section != null) {
      section.flex = newFlex;
      _persist();
    }
  }

  /// Adjusts the flex of a section and its neighbor to achieve a resize.
  ///
  /// When the user drags the handle between section A (top) and section B
  /// (bottom) by [deltaDy] pixels, section A's flex decreases and B's
  /// increases by the same amount, keeping the total constant.
  void resizeSection(
      String swimlaneId, String sectionId, double deltaDy) {
    final swimlane = _findSwimlane(swimlaneId);
    if (swimlane == null) return;
    final sections = swimlane.sections;
    final idx = sections.indexWhere((s) => s.sectionId == sectionId);
    if (idx == -1 || idx >= sections.length - 1) return;

    final top = sections[idx];
    final bottom = sections[idx + 1];
    final topFlex = top.flex ?? 1.0;
    final bottomFlex = bottom.flex ?? 1.0;

    // deltaDy > 0 means dragging down → top grows, bottom shrinks
    final change = deltaDy.abs();
    if (deltaDy > 0) {
      // Dragging down: top section gets bigger
      top.flex = (topFlex + change).clamp(0.1, 100.0);
      bottom.flex = (bottomFlex - change).clamp(0.1, 100.0);
    } else {
      // Dragging up: top section gets smaller
      top.flex = (topFlex - change).clamp(0.1, 100.0);
      bottom.flex = (bottomFlex + change).clamp(0.1, 100.0);
    }
    _persist();
  }

  /// Moves a section from one swimlane to another.
  void moveSection({
    required String fromSwimlaneId,
    required String toSwimlaneId,
    required String sectionId,
    int? toIndex,
  }) {
    final fromSwimlane = _findSwimlane(fromSwimlaneId);
    final toSwimlane = _findSwimlane(toSwimlaneId);
    if (fromSwimlane == null || toSwimlane == null) return;

    final section = fromSwimlane.removeSection(sectionId);
    if (section != null) {
      toSwimlane.addSection(section, index: toIndex);
      _persist();
    }
  }

  /// Moves a pane from one section to another (possibly across swimlanes).
  void movePane({
    required String fromSwimlaneId,
    required String fromSectionId,
    required String toSwimlaneId,
    required String toSectionId,
    required String paneId,
    int? toIndex,
  }) {
    final fromSection = _findSection(fromSwimlaneId, fromSectionId);
    final toSection = _findSection(toSwimlaneId, toSectionId);
    if (fromSection == null || toSection == null) return;

    final pane = fromSection.removePane(paneId);
    if (pane != null) {
      if (toIndex != null && toIndex >= 0 && toIndex <= toSection.panes.length) {
        toSection.panes.insert(toIndex, pane);
      } else {
        toSection.panes.add(pane);
      }
      if (toSection.activePaneId == null) {
        toSection.activePaneId = pane.paneId;
      }
      _persist();
    }
  }

  // ── Snapshot management ──

  /// Saves the current layout as a new named snapshot.
  Future<void> saveAsNewLayout(String name) async {
    if (_activeLayout == null) return;
    final newLayout = LayoutState(
      layoutName: name,
      swimlanes: _activeLayout!.swimlanes
          .map((s) => Swimlane.fromJson(s.toJson()))
          .toList(),
    );
    _layouts.add(newLayout);
    await _persist();
  }

  /// Switches to a different layout snapshot by ID.
  ///
  /// The active layout updates synchronously (listeners fire immediately);
  /// persistence is queued in the background so tab switches stay snappy.
  Future<void> switchLayout(String snapshotId) async {
    _activeLayout?.isCurrentActive = false;
    _activeLayout = _layouts.firstWhere(
      (l) => l.snapshotId == snapshotId,
      orElse: () => _layouts.first,
    );
    _activeLayout!.isCurrentActive = true;
    notifyListeners();
    _persist();
  }

  /// Deletes a layout snapshot. System defaults and the active layout cannot be deleted.
  Future<bool> deleteLayout(String snapshotId) async {
    final target = _layouts.firstWhere(
      (l) => l.snapshotId == snapshotId,
      orElse: () => throw StateError('Layout not found'),
    );
    if (target.isSystemDefault || target.isCurrentActive) return false;
    _layouts.removeWhere((l) => l.snapshotId == snapshotId);
    await _persist();
    return true;
  }

  /// Renames a layout snapshot.
  Future<void> renameLayout(String snapshotId, String newName) async {
    final target = _layouts.where((l) => l.snapshotId == snapshotId);
    if (target.isNotEmpty) {
      target.first.layoutName = newName;
      await _persist();
    }
  }

  /// Resets the active layout to the system default.
  Future<void> resetToDefault() async {
    final defaults = LayoutState.systemDefault();
    for (final layout in _layouts) {
      layout.isCurrentActive = false;
    }
    _layouts.removeWhere((layout) => layout.isSystemDefault);
    _layouts.insert(0, defaults);
    _activeLayout = defaults;
    await _persist();
  }

  // ── Helpers ──

  Swimlane? _findSwimlane(String swimlaneId) {
    return _activeLayout?.swimlanes
        .where((s) => s.id == swimlaneId)
        .firstOrNull;
  }

  Section? _findSection(String swimlaneId, String sectionId) {
    final swimlane = _findSwimlane(swimlaneId);
    return swimlane?.sections
        .where((s) => s.sectionId == sectionId)
        .firstOrNull;
  }

  @override
  void dispose() {
    themeManager.removeListener(() => notifyListeners());
    themeManager.dispose();
    super.dispose();
  }

  /// For testing: synchronously notify listeners.
  @visibleForTesting
  void syncNotify() => notifyListeners();
}
