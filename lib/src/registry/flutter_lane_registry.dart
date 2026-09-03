import 'package:flutter/material.dart';

/// ── Meta structs for each registration dimension ──

/// Metadata for a top-level window view registration.
class WindowViewMeta {
  final String viewTypeId;
  final String viewName;
  final IconData icon;
  final bool canPinned;
  final bool keepAlive;
  final Widget Function(BuildContext context) viewBuilder;
  final List<String> supportBusinessContexts;

  const WindowViewMeta({
    required this.viewTypeId,
    required this.viewName,
    required this.icon,
    this.canPinned = false,
    this.keepAlive = false,
    required this.viewBuilder,
    this.supportBusinessContexts = const [],
  });
}

/// Metadata for a workspace-pane business view registration.
class ViewInstanceMeta {
  final String viewTypeId;
  final String viewDisplayName;
  final IconData icon;
  final bool isSystemBuiltIn;
  final List<String> supportBusinessContexts;
  final Widget Function(BuildContext context, String businessContext,
      Map<String, dynamic> viewState) viewBuilder;
  final Map<String, dynamic> defaultViewState;

  const ViewInstanceMeta({
    required this.viewTypeId,
    required this.viewDisplayName,
    required this.icon,
    this.isSystemBuiltIn = false,
    this.supportBusinessContexts = const [],
    required this.viewBuilder,
    this.defaultViewState = const {},
  });
}

/// Metadata for a top-bar action button registration.
class HeaderActionMeta {
  final String actionId;
  final String actionName;
  final IconData icon;
  final String? shortcutKey;
  final bool disabled;
  final VoidCallback onTap;
  final List<String>? bindBusinessContexts;
  final bool alwaysVisible;

  const HeaderActionMeta({
    required this.actionId,
    required this.actionName,
    required this.icon,
    this.shortcutKey,
    this.disabled = false,
    required this.onTap,
    this.bindBusinessContexts,
    this.alwaysVisible = true,
  });
}

/// Metadata for a bottom status-bar item registration.
class StatusBarItemMeta {
  final String itemId;
  final int sortWeight;
  final IconData? icon;
  final String Function() textBuilder;
  final String? tooltip;
  final bool isSpacer;
  final List<String>? bindBusinessContexts;
  final VoidCallback? onTap;

  const StatusBarItemMeta({
    required this.itemId,
    this.sortWeight = 0,
    this.icon,
    required this.textBuilder,
    this.tooltip,
    this.isSpacer = false,
    this.bindBusinessContexts,
    this.onTap,
  });
}

/// ── Registry ──

/// Global registration center for all pluggable views and actions.
///
/// Business code registers views/actions/status-items once; the layout engine
/// consumes them for rendering without any business coupling.
class FlutterLaneRegistry {
  final Map<String, WindowViewMeta> _windowViews = {};
  final Map<String, ViewInstanceMeta> _paneViews = {};
  final Map<String, HeaderActionMeta> _headerActions = {};
  final Map<String, StatusBarItemMeta> _statusBarItems = {};

  // ── Window Views ──

  void registerWindowView(WindowViewMeta meta) {
    _windowViews[meta.viewTypeId] = meta;
  }

  void unregisterWindowView(String viewTypeId) {
    _windowViews.remove(viewTypeId);
  }

  WindowViewMeta? getWindowView(String viewTypeId) => _windowViews[viewTypeId];
  List<WindowViewMeta> get allWindowViews => _windowViews.values.toList();

  // ── Pane Views ──

  void registerPaneView(ViewInstanceMeta meta) {
    _paneViews[meta.viewTypeId] = meta;
  }

  void unregisterPaneView(String viewTypeId) {
    _paneViews.remove(viewTypeId);
  }

  ViewInstanceMeta? getPaneView(String viewTypeId) => _paneViews[viewTypeId];
  List<ViewInstanceMeta> get allPaneViews => _paneViews.values.toList();

  /// Returns pane views compatible with the given business context.
  List<ViewInstanceMeta> getPaneViewsForContext(String businessContext) {
    return _paneViews.values
        .where((m) =>
            m.supportBusinessContexts.isEmpty ||
            m.supportBusinessContexts.contains(businessContext))
        .toList();
  }

  // ── Header Actions ──

  void registerHeaderAction(HeaderActionMeta meta) {
    _headerActions[meta.actionId] = meta;
  }

  void unregisterHeaderAction(String actionId) {
    _headerActions.remove(actionId);
  }

  HeaderActionMeta? getHeaderAction(String actionId) =>
      _headerActions[actionId];
  List<HeaderActionMeta> get allHeaderActions => _headerActions.values.toList();

  // ── Status Bar Items ──

  void registerStatusBarItem(StatusBarItemMeta meta) {
    _statusBarItems[meta.itemId] = meta;
  }

  void unregisterStatusBarItem(String itemId) {
    _statusBarItems.remove(itemId);
  }

  StatusBarItemMeta? getStatusBarItem(String itemId) => _statusBarItems[itemId];

  /// Returns status bar items sorted by [StatusBarItemMeta.sortWeight].
  List<StatusBarItemMeta> get allStatusBarItems {
    final items = _statusBarItems.values.toList();
    items.sort((a, b) => a.sortWeight.compareTo(b.sortWeight));
    return items;
  }

  // ── Bulk clear ──

  void clearAll() {
    _windowViews.clear();
    _paneViews.clear();
    _headerActions.clear();
    _statusBarItems.clear();
  }
}
