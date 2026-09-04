import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/flutter_lane_manager.dart';
import '../models/chrome_header_action.dart';
import '../models/chrome_menu_item.dart';
import '../theme/flutter_lane_theme.dart';
import 'flutter_lane_workbench.dart';
import 'tab_bar/window_tab_bar.dart';

/// A complete Chrome-style shell that wraps [FlutterLaneWorkbench] with:
///
/// - **Header bar**: traffic light buttons (close/minimize/maximize),
///   a ☰ hamburger menu, the [WindowTabBar], and action buttons.
/// - **Workbench**: the resizable swimlane layout (delegates to
///   [FlutterLaneWorkbench]).
/// - **Status bar**: swimlane/section/pane counts and layout name.
///
/// Developers only need to provide [menuItems] and optionally
/// [headerActions] — everything else is handled by the library.
///
/// ```dart
/// FlutterLaneChrome(
///   manager: myManager,
///   menuItems: [
///     FlutterLaneMenuItem(label: 'Save', icon: Icons.save, shortcut: 'Ctrl+S', onTap: save),
///     FlutterLaneMenuItem.divider(),
///     FlutterLaneMenuItem(label: 'Exit', icon: Icons.exit_to_app, onTap: exit),
///   ],
///   headerActions: [
///     FlutterLaneHeaderAction(icon: Icons.play_arrow, tooltip: 'Run', onTap: run),
///   ],
/// )
/// ```
class FlutterLaneChrome extends StatefulWidget {
  final FlutterLaneManager manager;

  /// Menu items shown in the ☰ hamburger dropdown.
  final List<FlutterLaneMenuItem> menuItems;

  /// Optional extra action buttons on the right side of the header.
  /// The built-in save/theme/reset buttons are always present.
  final List<FlutterLaneHeaderAction> headerActions;

  /// Optional callback when the "Save Layout" button is tapped.
  /// If null, a default dialog is shown.
  final VoidCallback? onSaveLayout;

  /// Optional callback when the "Reset Layout" button is tapped.
  final VoidCallback? onResetLayout;

  /// Window tab bar controller. If null, no window tabs are shown.
  final TabBarController? windowTabController;

  /// Label for the "new tab" button in the window tab bar.
  final String newTabLabel;

  const FlutterLaneChrome({
    super.key,
    required this.manager,
    this.menuItems = const [],
    this.headerActions = const [],
    this.onSaveLayout,
    this.onResetLayout,
    this.windowTabController,
    this.newTabLabel = 'New Window',
  });

  @override
  State<FlutterLaneChrome> createState() => _FlutterLaneChromeState();
}

class _FlutterLaneChromeState extends State<FlutterLaneChrome> {
  FlutterLaneManager get _mgr => widget.manager;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _mgr,
      builder: (context, _) {
        final theme = _mgr.currentTheme;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: theme.swimlaneBackground,
          ),
          home: Scaffold(
            backgroundColor: theme.swimlaneBackground,
            body: Column(
              children: [
                _ChromeHeader(
                  manager: _mgr,
                  menuItems: widget.menuItems,
                  headerActions: widget.headerActions,
                  onSaveLayout: widget.onSaveLayout,
                  onResetLayout: widget.onResetLayout,
                  windowTabController: widget.windowTabController,
                  newTabLabel: widget.newTabLabel,
                ),
                Expanded(
                  child: FlutterLaneWorkbench(manager: _mgr),
                ),
                _StatusBar(manager: _mgr),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// Header
// ============================================================

class _ChromeHeader extends StatefulWidget {
  final FlutterLaneManager manager;
  final List<FlutterLaneMenuItem> menuItems;
  final List<FlutterLaneHeaderAction> headerActions;
  final VoidCallback? onSaveLayout;
  final VoidCallback? onResetLayout;
  final TabBarController? windowTabController;
  final String newTabLabel;

  const _ChromeHeader({
    required this.manager,
    required this.menuItems,
    required this.headerActions,
    this.onSaveLayout,
    this.onResetLayout,
    this.windowTabController,
    required this.newTabLabel,
  });

  @override
  State<_ChromeHeader> createState() => _ChromeHeaderState();
}

class _ChromeHeaderState extends State<_ChromeHeader> {
  final GlobalKey _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = widget.manager.currentTheme;

    return Container(
      height: 42,
      color: theme.headerBarBackground,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // Traffic lights
          Row(
            children: [
              _TrafficDot(
                color: const Color(0xFFff5f57),
                tooltip: 'Close',
                onTap: () => windowManager.close(),
              ),
              const SizedBox(width: 8),
              _TrafficDot(
                color: const Color(0xFFfebc2e),
                tooltip: 'Minimize',
                onTap: () => windowManager.minimize(),
              ),
              const SizedBox(width: 8),
              _TrafficDot(
                color: const Color(0xFF28c840),
                tooltip: 'Maximize',
                onTap: () async {
                  final maxed = await windowManager.isMaximized();
                  maxed ? windowManager.unmaximize() : windowManager.maximize();
                },
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Hamburger menu
          if (widget.menuItems.isNotEmpty)
            GestureDetector(
              key: _menuKey,
              onTap: _showMenu,
              child: Icon(Icons.menu, size: 14, color: theme.headerBarTextColor),
            ),
          const SizedBox(width: 12),
          // Window tabs
          if (widget.windowTabController != null)
            Flexible(
              child: SizedBox(
                height: 38,
                child: WindowTabBar(
                  controller: widget.windowTabController!,
                  newTabLabel: widget.newTabLabel,
                  style: TabBarStyle.fromFlutterLaneTheme(theme),
                ),
              ),
            ),
          const Spacer(),
          // Custom header actions
          for (final action in widget.headerActions)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(action.icon, size: 15, color: theme.headerBarTextColor),
                tooltip: action.tooltip,
                onPressed: action.onTap,
              ),
            ),
          // Built-in: Save layout
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(Icons.save_outlined, size: 15, color: theme.headerBarTextColor),
              tooltip: 'Save current layout',
              onPressed: widget.onSaveLayout ?? () => _showSaveDialog(context),
            ),
          ),
          // Built-in: Cycle theme
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(_themeIcon(), size: 15, color: theme.headerBarTextColor),
              tooltip: _themeTooltip(),
              onPressed: () => widget.manager.themeManager.cycleTheme(),
            ),
          ),
          // Built-in: Reset layout
          if (widget.onResetLayout != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(Icons.restore, size: 15, color: theme.headerBarTextColor),
                tooltip: 'Reset to default layout',
                onPressed: widget.onResetLayout,
              ),
            ),
        ],
      ),
    );
  }

  IconData _themeIcon() {
    final activeId = widget.manager.themeManager.activeCustomThemeId;
    if (activeId == 'ocean') return Icons.water;
    if (activeId == 'ember') return Icons.local_fire_department;
    final t = widget.manager.themeManager.currentType;
    if (t == FlutterLaneThemeType.dark) return Icons.light_mode;
    if (t == FlutterLaneThemeType.light) return Icons.dark_mode;
    return Icons.contrast;
  }

  String _themeTooltip() {
    final activeId = widget.manager.themeManager.activeCustomThemeId;
    if (activeId != null) return 'Theme: $activeId';
    return 'Theme: ${widget.manager.themeManager.currentType.name}';
  }

  void _showMenu() {
    final theme = widget.manager.currentTheme;
    final RenderBox? box =
        _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);

    final items = <PopupMenuEntry<String>>[
      for (int i = 0; i < widget.menuItems.length; i++) ...[
        if (i > 0 && widget.menuItems[i].isDivider)
          const PopupMenuDivider()
        else if (!widget.menuItems[i].isDivider)
          _buildPopupItem(widget.menuItems[i], theme),
      ],
    ];

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + box.size.height,
        offset.dx + 250,
        offset.dy + box.size.height + 400,
      ),
      items: items,
      color: theme.sectionBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: theme.sectionBorderColor),
      ),
      elevation: 8,
    );
  }

  PopupMenuItem<String> _buildPopupItem(
      FlutterLaneMenuItem item, FlutterLaneThemeData theme) {
    return PopupMenuItem(
      value: item.label,
      height: 32,
      child: Row(
        children: [
          Icon(item.icon, size: 14, color: theme.tabInactiveTextColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item.label ?? '',
                style:
                    TextStyle(fontSize: 12, color: theme.sectionHeaderTextColor)),
          ),
          if (item.shortcut != null && item.shortcut!.isNotEmpty)
            Text(
              item.shortcut!,
              style: TextStyle(
                fontSize: 11,
                color: theme.tabInactiveTextColor.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Layout'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Layout name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                widget.manager.saveAsNewLayout(controller.text);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Traffic dot
// ============================================================

class _TrafficDot extends StatelessWidget {
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _TrafficDot({
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Status bar
// ============================================================

class _StatusBar extends StatelessWidget {
  final FlutterLaneManager manager;

  const _StatusBar({required this.manager});

  @override
  Widget build(BuildContext context) {
    final theme = manager.currentTheme;
    final active = manager.activeLayout;
    final swimlaneCount = active?.swimlanes.length ?? 0;
    final sectionCount = active?.swimlanes.fold<int>(
          0,
          (sum, s) => sum + s.sections.length,
        ) ??
        0;
    final paneCount = active?.swimlanes.fold<int>(
          0,
          (sum, lane) =>
              sum +
              lane.sections.fold<int>(
                0,
                (acc, section) => acc + section.panes.length,
              ),
        ) ??
        0;

    return Container(
      height: 22,
      color: theme.statusBarBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            '$swimlaneCount swimlanes · $sectionCount sections · $paneCount panes',
            style: TextStyle(
              fontSize: 11,
              color: theme.statusBarTextColor,
            ),
          ),
          const Spacer(),
          Text(
            'Layout: ${active?.layoutName ?? 'None'}',
            style: TextStyle(
              fontSize: 11,
              color: theme.statusBarTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
