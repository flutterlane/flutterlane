import 'package:flutter/material.dart';
import 'package:flutterlane/flutterlane.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  const opts = WindowOptions(size: Size(1400, 900), center: true);
  windowManager.waitUntilReadyToShow(opts, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const FlutterLaneExampleApp());
}

// ============================================================
// Custom themes — registered alongside the 3 built-in themes
// so cycleTheme cycles: light → dark → pure → ocean → ember → light
// ============================================================

const _oceanTheme = FlutterLaneThemeData(
  swimlaneBackground: Color(0xFF0B1D33),
  swimlaneDivider: Color(0xFF123456),
  sectionBackground: Color(0xFF0F2744),
  sectionHeaderBackground: Color(0xFF0B1D33),
  sectionHeaderTextColor: Color(0xFF4FC3F7),
  sectionBorderColor: Color(0xFF1A3A5C),
  tabBarBackground: Color(0xFF0D2137),
  tabActiveBackground: Color(0xFF0F3460),
  tabActiveTextColor: Color(0xFFE1F5FE),
  tabInactiveTextColor: Color(0xFF6B8DAE),
  tabHoverBackground: Color(0xFF1A4A7A),
  tabBorderColor: Color(0xFF1A3A5C),
  paneContentBackground: Color(0xFF0F2744),
  resizeHandleColor: Color(0xFF1A4A7A),
  resizeHandleHoverColor: Color(0xFF4FC3F7),
  hoverZoneColor: Color(0x204FC3F7),
  hoverZoneActiveColor: Color(0x604FC3F7),
  dragPlaceholderColor: Color(0x304FC3F7),
  dragPreviewColor: Color(0x801A4A7A),
  tooltipBackground: Color(0xFF0D2137),
  tooltipTextColor: Color(0xFFE1F5FE),
  statusBarBackground: Color(0xFF1A4A7A),
  statusBarTextColor: Color(0xFFE1F5FE),
  headerBarBackground: Color(0xFF0B1D33),
  headerBarTextColor: Color(0xFF4FC3F7),
  scrollbarThumbColor: Color(0xFF1A4A7A),
  scrollbarTrackColor: Color(0x00000000),
);

const _emberTheme = FlutterLaneThemeData(
  swimlaneBackground: Color(0xFF1A0A00),
  swimlaneDivider: Color(0xFF3D1C00),
  sectionBackground: Color(0xFF241200),
  sectionHeaderBackground: Color(0xFF1A0A00),
  sectionHeaderTextColor: Color(0xFFFFAB40),
  sectionBorderColor: Color(0xFF4E2600),
  tabBarBackground: Color(0xFF1F0E00),
  tabActiveBackground: Color(0xFF5D2E00),
  tabActiveTextColor: Color(0xFFFFF3E0),
  tabInactiveTextColor: Color(0xFFBF8040),
  tabHoverBackground: Color(0xFF7A3D00),
  tabBorderColor: Color(0xFF4E2600),
  paneContentBackground: Color(0xFF241200),
  resizeHandleColor: Color(0xFF7A3D00),
  resizeHandleHoverColor: Color(0xFFFFAB40),
  hoverZoneColor: Color(0x20FFAB40),
  hoverZoneActiveColor: Color(0x60FFAB40),
  dragPlaceholderColor: Color(0x30FFAB40),
  dragPreviewColor: Color(0x807A3D00),
  tooltipBackground: Color(0xFF1F0E00),
  tooltipTextColor: Color(0xFFFFF3E0),
  statusBarBackground: Color(0xFF7A3D00),
  statusBarTextColor: Color(0xFFFFF3E0),
  headerBarBackground: Color(0xFF1A0A00),
  headerBarTextColor: Color(0xFFFFAB40),
  scrollbarThumbColor: Color(0xFF7A3D00),
  scrollbarTrackColor: Color(0x00000000),
);

// ============================================================
// Workspace dataset — each window tab binds to one workspace.
// Workspaces share view types (editor, explorer, terminal, ...)
// but each renders its own data through ViewInstance.businessContext.
// ============================================================

class _WorkspaceFile {
  final String name;
  final String content;
  const _WorkspaceFile(this.name, this.content);
}

class _TreeNode {
  final String name;
  final bool isFolder;
  final List<_TreeNode> children;
  const _TreeNode.folder(this.name, [this.children = const []])
      : isFolder = true;
  const _TreeNode.file(this.name)
      : isFolder = false,
        children = const [];
}

enum _WorkspaceLayoutKind { fullIde, docs, repo, minimal }

class _Workspace {
  final String id;
  final String title;
  final String url;
  final bool closable;
  final _WorkspaceLayoutKind layoutKind;
  final List<_TreeNode> tree;
  final List<_WorkspaceFile> files;
  final String defaultFile;

  const _Workspace({
    required this.id,
    required this.title,
    required this.url,
    required this.closable,
    required this.layoutKind,
    required this.tree,
    required this.files,
    required this.defaultFile,
  });

  String contentOf(String name) {
    for (final f in files) {
      if (f.name == name) return f.content;
    }
    return '';
  }
}

const List<_Workspace> _kWorkspaces = [
  // ── FlutterLane — product site (the default, non-closable tab) ──
  _Workspace(
    id: 'flutterlane',
    title: 'FlutterLane',
    url: 'flutterlane.dev',
    closable: false,
    layoutKind: _WorkspaceLayoutKind.fullIde,
    tree: [
      _TreeNode.folder('src', [
        _TreeNode.folder('core', [
          _TreeNode.file('flutter_lane_manager.dart'),
        ]),
        _TreeNode.folder('models', [
          _TreeNode.file('swimlane.dart'),
          _TreeNode.file('section.dart'),
        ]),
      ]),
      _TreeNode.folder('example', [
        _TreeNode.file('main.dart'),
      ]),
      _TreeNode.file('pubspec.yaml'),
      _TreeNode.file('README.md'),
    ],
    files: [
      _WorkspaceFile('README.md', '''
# FlutterLane

A dockable, drag-and-drop layout engine for Flutter.

## Features
- Swimlanes, sections and panes
- Drag & drop reorganization
- Persisted layouts & themes

## Install
flutter pub add flutterlane
'''),
      _WorkspaceFile('CHANGELOG.md', '''
# Changelog

## 0.4.0
- Window tabs with per-tab workspace layouts
- Long-press swimlane drag

## 0.3.0
- Section collapse, resize & close
'''),
    ],
    defaultFile: 'README.md',
  ),

  // ── Design Docs — documentation site with markdown preview ──
  _Workspace(
    id: 'designdocs',
    title: 'Design Docs',
    url: 'docs.flutterlane.dev',
    closable: true,
    layoutKind: _WorkspaceLayoutKind.docs,
    tree: [
      _TreeNode.folder('docs', [
        _TreeNode.file('index.md'),
        _TreeNode.folder('guides', [
          _TreeNode.file('layout.md'),
        ]),
        _TreeNode.folder('api', [
          _TreeNode.file('swimlane.md'),
        ]),
      ]),
    ],
    files: [
      _WorkspaceFile('docs/index.md', '''
# Design Docs

Documentation for the FlutterLane design system.

## Layout Engine
Swimlanes organize the window into resizable columns.
Sections stack vertically inside a swimlane.

## Theming
Every surface color comes from FlutterLaneThemeData.
'''),
      _WorkspaceFile('docs/guides/layout.md', '''
# Layout Guide

## Swimlanes
Swimlanes are horizontal columns. Each holds sections.

## Sections
Sections stack vertically and can be collapsed.
'''),
      _WorkspaceFile('docs/api/swimlane.md', '''
# Swimlane API

## Swimlane
- id: String
- flex: double
- fixedWidth: double?
- sections: List<Section>
'''),
    ],
    defaultFile: 'docs/index.md',
  ),

  // ── GitHub — source repository browsing ──
  _Workspace(
    id: 'github',
    title: 'GitHub',
    url: 'github.com/flutterlane',
    closable: true,
    layoutKind: _WorkspaceLayoutKind.repo,
    tree: [
      _TreeNode.file('README.md'),
      _TreeNode.file('CONTRIBUTING.md'),
      _TreeNode.folder('lib', [
        _TreeNode.file('main.dart'),
      ]),
    ],
    files: [
      _WorkspaceFile('README.md', '''
# flutterlane

VS Code-style workspaces in Flutter.

## Repository
- lib/ — layout engine
- example/ — demo workspace
'''),
      _WorkspaceFile('CONTRIBUTING.md', '''
# Contributing

1. Fork the repository
2. Create a feature branch
3. Open a pull request
'''),
    ],
    defaultFile: 'README.md',
  ),

  // ── Minimal — lightweight workspace for quick notes ──
  _Workspace(
    id: 'minimal',
    title: 'Notes',
    url: 'local',
    closable: true,
    layoutKind: _WorkspaceLayoutKind.minimal,
    tree: [
      _TreeNode.file('scratch.md'),
      _TreeNode.file('todo.md'),
    ],
    files: [
      _WorkspaceFile('scratch.md', '''# Scratch Notes

- [ ] Finish integrating FlutterLane
- [x] Add workspace isolation
- [x] Multi-theme support
- Review PR #42
'''),
      _WorkspaceFile('todo.md', '''# TODO

1. Deploy to staging
2. Write release notes
3. Update changelog
'''),
    ],
    defaultFile: 'scratch.md',
  ),
];

_Workspace _workspaceById(String id) {
  for (final ws in _kWorkspaces) {
    if (ws.id == id) return ws;
  }
  return _kWorkspaces.first;
}

IconData _themeIcon(FlutterLaneManager mgr) {
  final activeId = mgr.themeManager.activeCustomThemeId;
  if (activeId == 'ocean') return Icons.water;
  if (activeId == 'ember') return Icons.local_fire_department;
  final t = mgr.themeManager.currentType;
  if (t == FlutterLaneThemeType.dark) return Icons.light_mode;
  if (t == FlutterLaneThemeType.light) return Icons.dark_mode;
  return Icons.contrast;
}

String _themeTooltip(FlutterLaneManager mgr) {
  final activeId = mgr.themeManager.activeCustomThemeId;
  if (activeId != null) return 'Theme: $activeId (cycle)';
  final t = mgr.themeManager.currentType;
  return 'Theme: ${t.name} (cycle)';
}

// ============================================================
// App
// ============================================================

class FlutterLaneExampleApp extends StatefulWidget {
  const FlutterLaneExampleApp({super.key});

  @override
  State<FlutterLaneExampleApp> createState() => _FlutterLaneExampleAppState();
}

class _FlutterLaneExampleAppState extends State<FlutterLaneExampleApp> {
  final Map<String, FlutterLaneManager> _managers = {};
  final TabBarController _windowTabs = TabBarController(
    initialTabs: [
      for (final ws in _kWorkspaces)
        TabData(
          title: ws.title,
          url: ws.url,
          businessId: ws.id,
          closable: ws.closable,
        ),
    ],
  );

  FlutterLaneManager get _manager =>
      _managers[_activeWorkspaceId] ?? _managers.values.first;

  String _activeWorkspaceId = _kWorkspaces.first.id;

  /// Shared "open file" per workspace so clicking a markdown file in the
  /// Explorer opens it in the Editor (and Preview) panes of that workspace.
  final Map<String, ValueNotifier<String>> _openFiles = {};
  String _activeActivity = 'explorer';
  bool _ready = false;

  ValueNotifier<String> _openFileFor(_Workspace ws) => _openFiles.putIfAbsent(
        ws.id,
        () => ValueNotifier<String>(ws.defaultFile),
      );

  @override
  void initState() {
    super.initState();
    _windowTabs.onChange = _handleWindowTabChange;
    _init();
  }

  Future<void> _init() async {
    // Create one isolated manager per workspace.
    for (final ws in _kWorkspaces) {
      final workspace = Workspace(
        workspaceId: ws.id,
        workspaceName: ws.title,
        themeType: FlutterLaneThemeType.dark,
      );
      final mgr = FlutterLaneManager(
        workspace: workspace,
        defaultSwimlanes: _buildWorkspaceLayout(ws),
      );
      _registerViews(mgr, ws);
      await mgr.init();
      mgr.themeManager.registerCustomTheme('ocean', _oceanTheme);
      mgr.themeManager.registerCustomTheme('ember', _emberTheme);
      _managers[ws.id] = mgr;

      // Ensure a persisted layout snapshot exists for this workspace.
      if (mgr.layouts.length <= 1 && mgr.layouts.first.isSystemDefault) {
        final snapshot = LayoutState(
          layoutName: ws.title,
          swimlanes: _buildWorkspaceLayout(ws),
        );
        await mgr.addLayoutSnapshot(snapshot);
        await mgr.switchLayout(snapshot.snapshotId);
      }
    }

    // Apply the dedicated layout of the currently active tab.
    await _applyLayoutForActiveTab();

    setState(() => _ready = true);
  }

  void _registerViews(FlutterLaneManager mgr, _Workspace ws) {
    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'explorer',
      viewDisplayName: 'Explorer',
      icon: Icons.folder_outlined,
      isSystemBuiltIn: true,
      viewBuilder: (ctx, bizCtx, state) {
        return _ExplorerView(
          workspace: ws,
          openFile: _openFileFor(ws),
          onOpenFile: (name) => _openFileFor(ws).value = name,
        );
      },
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'search',
      viewDisplayName: 'Search',
      icon: Icons.search,
      viewBuilder: (ctx, bizCtx, state) => const _SearchView(),
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'terminal',
      viewDisplayName: 'Terminal',
      icon: Icons.terminal,
      viewBuilder: (ctx, bizCtx, state) =>
          _TerminalView(workspace: ws),
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'output',
      viewDisplayName: 'Output',
      icon: Icons.output,
      viewBuilder: (ctx, bizCtx, state) => const _OutputView(),
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'problems',
      viewDisplayName: 'Problems',
      icon: Icons.error_outline,
      viewBuilder: (ctx, bizCtx, state) => const _ProblemsView(),
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'debug_console',
      viewDisplayName: 'Debug Console',
      icon: Icons.bug_report,
      viewBuilder: (ctx, bizCtx, state) => const _DebugConsoleView(),
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'ports',
      viewDisplayName: 'Ports',
      icon: Icons.lan,
      viewBuilder: (ctx, bizCtx, state) => const _PortsView(),
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'git',
      viewDisplayName: 'Source Control',
      icon: Icons.account_tree_outlined,
      viewBuilder: (ctx, bizCtx, state) =>
          _GitView(workspace: ws),
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'settings',
      viewDisplayName: 'Settings',
      icon: Icons.tune,
      viewBuilder: (ctx, bizCtx, state) => const _SettingsView(),
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'preview',
      viewDisplayName: 'Preview',
      icon: Icons.visibility,
      viewBuilder: (ctx, bizCtx, state) {
        return _MarkdownPreviewView(
          workspace: ws,
          openFile: _openFileFor(ws),
        );
      },
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'activitybar',
      viewDisplayName: 'Activity Bar',
      icon: Icons.apps,
      viewBuilder: (ctx, bizCtx, state) => _ActivityBar(
        manager: mgr,
        activeActivity: _activeActivity,
        onActivityTap: _handleActivityTap,
      ),
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'editor',
      viewDisplayName: 'Editor',
      icon: Icons.code,
      viewBuilder: (ctx, bizCtx, state) {
        return _EditorView(
          workspace: ws,
          openFile: _openFileFor(ws),
        );
      },
    ));

    mgr.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'copilot',
      viewDisplayName: 'Copilot',
      icon: Icons.auto_fix_high,
      viewBuilder: (ctx, bizCtx, state) => _CopilotPane(manager: mgr),
    ));
  }

  /// Switching/adding/closing a window tab opens that tab's own layout.
  void _handleWindowTabChange(TabBarChangeEvent e) {
    if (e.type == TabChangeType.update) return;
    _applyLayoutForActiveTab();
  }

  /// ActivityBar: clicking an icon (e.g. folder_copy_rounded) shows the
  /// dedicated layout of the *currently active* window tab.
  void _handleActivityTap(String activityId) {
    setState(() => _activeActivity = activityId);
    _applyLayoutForActiveTab();
  }

  Future<void> _applyLayoutForActiveTab() async {
    final activeId = _windowTabs.active();
    final tab = activeId == null
        ? _windowTabs.tabs.first
        : (_windowTabs.get(activeId) ?? _windowTabs.tabs.first);
    final ws = _workspaceById(tab.businessId ?? tab.id ?? _kWorkspaces.first.id);

    // Switch to this workspace's manager.
    if (_activeWorkspaceId != ws.id) {
      _activeWorkspaceId = ws.id;
    }

    final mgr = _manager;
    if (mgr.activeLayout == null) return;

    // Find the layout snapshot for this workspace and activate it.
    LayoutState? snapshot;
    for (final l in mgr.layouts) {
      if (l.layoutName == ws.title && !l.isSystemDefault) {
        snapshot = l;
        break;
      }
    }
    snapshot ??= mgr.layouts.firstWhere(
      (l) => !l.isSystemDefault,
      orElse: () => mgr.layouts.first,
    );
    if (mgr.activeLayout?.snapshotId != snapshot.snapshotId) {
      await mgr.switchLayout(snapshot.snapshotId);
    }
    if (mounted) setState(() {});
  }

  // ── Layout builders ──

  List<Swimlane> _buildWorkspaceLayout(_Workspace ws) {
    switch (ws.layoutKind) {
      case _WorkspaceLayoutKind.fullIde:
        return _buildFullIdeLayout(ws);
      case _WorkspaceLayoutKind.docs:
        return _buildDocsLayout(ws);
      case _WorkspaceLayoutKind.repo:
        return _buildRepoLayout(ws);
      case _WorkspaceLayoutKind.minimal:
        return _buildMinimalLayout(ws);
    }
  }

  Pane _pane(String viewTypeId, _Workspace ws) => Pane(
        paneId: generateId(),
        viewInstance: ViewInstance(viewTypeId: viewTypeId),
      );

  Swimlane _activityBarLane() {
    final section = Section(title: '', canToggle: false, canAddPane: false);
    section.addPane(Pane(
      paneId: generateId(),
      viewInstance: const ViewInstance(viewTypeId: 'activitybar'),
    ));
    return Swimlane(
      flex: 0,
      minWidth: 64,
      fixedWidth: 48,
      canClose: false,
      sections: [section],
    );
  }

  Swimlane _explorerLane(_Workspace ws) {
    final explorer = Section(title: 'Explorer', canToggle: true, canAddPane: true);
    explorer.addPane(_pane('explorer', ws));
    return Swimlane(flex: 20, minWidth: 150, canClose: true, sections: [explorer]);
  }

  /// Full IDE (default): activity bar | explorer | editor + operation | copilot
  List<Swimlane> _buildFullIdeLayout(_Workspace ws) {
    final editor = Section(title: 'Editor', canToggle: true, canAddPane: true);
    editor.addPane(_pane('editor', ws));

    final operation = Section(title: 'Operation', canToggle: true, canAddPane: true);
    operation
      ..addPane(_pane('problems', ws))
      ..addPane(_pane('output', ws))
      ..addPane(_pane('debug_console', ws))
      ..addPane(_pane('terminal', ws))
      ..addPane(_pane('ports', ws));

    final copilot = Section(title: 'Copilot', canToggle: true, canAddPane: true);
    copilot.addPane(_pane('copilot', ws));

    return [
      _activityBarLane(),
      _explorerLane(ws),
      Swimlane(
        flex: 50,
        minWidth: 300,
        canClose: true,
        sections: [editor, operation],
      ),
      Swimlane(flex: 22, minWidth: 200, canClose: true, sections: [copilot]),
    ];
  }

  /// Docs site: activity bar | explorer | editor + markdown preview
  List<Swimlane> _buildDocsLayout(_Workspace ws) {
    final editor = Section(title: 'Editor', canToggle: true, canAddPane: true);
    editor.addPane(_pane('editor', ws));

    final preview = Section(title: 'Preview', canToggle: true, canAddPane: true);
    preview.addPane(_pane('preview', ws));

    return [
      _activityBarLane(),
      _explorerLane(ws),
      Swimlane(
        flex: 50,
        minWidth: 300,
        canClose: true,
        sections: [editor, preview],
      ),
    ];
  }

  /// Repo browsing: activity bar | explorer | editor + terminal
  List<Swimlane> _buildRepoLayout(_Workspace ws) {
    final editor = Section(title: 'Editor', canToggle: true, canAddPane: true);
    editor.addPane(_pane('editor', ws));

    final terminal = Section(title: 'Terminal', canToggle: true, canAddPane: true);
    terminal.addPane(_pane('terminal', ws));

    return [
      _activityBarLane(),
      _explorerLane(ws),
      Swimlane(
        flex: 50,
        minWidth: 300,
        canClose: true,
        sections: [editor, terminal],
      ),
    ];
  }

  /// Minimal: just editor — no sidebar, for quick-edit workspaces.
  List<Swimlane> _buildMinimalLayout(_Workspace ws) {
    final editor = Section(title: 'Editor', canToggle: true, canAddPane: true);
    editor.addPane(_pane('editor', ws));

    return [
      Swimlane(
        flex: 100,
        minWidth: 300,
        canClose: true,
        sections: [editor],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _manager,
      builder: (context, _) {
        final theme = _manager.currentTheme;

        return MaterialApp(
          title: 'FlutterLane IDE Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: theme.swimlaneBackground,
            fontFamily: 'Roboto',
          ),
          home: Scaffold(
            backgroundColor: theme.swimlaneBackground,
            body: Column(
              children: [
                _ChromeHeader(
                  manager: _manager,
                  windowTabs: _windowTabs,
                  onResetLayout: _handleResetLayout,
                  onSelectLayout: _handleSelectLayout,
                ),
                Expanded(
                  child: FlutterLaneWorkbench(manager: _manager),
                ),
                _StatusBar(manager: _manager),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Layout dropdown: picking a workspace-bound snapshot activates its
  /// window tab (which applies that tab's dedicated layout). Generic
  /// user-saved snapshots just become the active layout.
  void _handleSelectLayout(String snapshotId) {
    final layout = _manager.layouts
        .where((l) => l.snapshotId == snapshotId)
        .firstOrNull;
    if (layout == null) return;
    _manager.switchLayout(snapshotId);
  }

  /// Reset to default layout: rebuild the default (FlutterLane) workspace's
  /// persisted snapshot from a pristine copy, then activate its tab.
  Future<void> _handleResetLayout() async {
    final defaultWs = _kWorkspaces.first;
    final mgr = _managers[defaultWs.id];
    if (mgr == null) return;

    // Find the workspace's named snapshot, or fall back to the first non-default.
    LayoutState? snapshot;
    for (final l in mgr.layouts) {
      if (l.layoutName == defaultWs.title && !l.isSystemDefault) {
        snapshot = l;
        break;
      }
    }
    snapshot ??= mgr.layouts.firstWhere(
      (l) => !l.isSystemDefault,
      orElse: () => mgr.layouts.first,
    );

    snapshot.swimlanes = _buildWorkspaceLayout(defaultWs);
    await mgr.save();
    if (mgr.activeLayout?.snapshotId != snapshot.snapshotId) {
      await mgr.switchLayout(snapshot.snapshotId);
    }
    final tab = _windowTabs.tabs.firstWhere(
      (t) => t.businessId == defaultWs.id,
      orElse: () => _windowTabs.tabs.first,
    );
    if (tab.id != null && _windowTabs.active() != tab.id) {
      _windowTabs.activate(tab.id!);
    }
    _activeWorkspaceId = defaultWs.id;
    if (mounted) setState(() {});
  }
}

// ============================================================
// Chrome header
// ============================================================

class _ChromeHeader extends StatefulWidget {
  final FlutterLaneManager manager;
  final TabBarController windowTabs;
  final VoidCallback onResetLayout;
  final ValueChanged<String> onSelectLayout;

  const _ChromeHeader({
    required this.manager,
    required this.windowTabs,
    required this.onResetLayout,
    required this.onSelectLayout,
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
          GestureDetector(
            key: _menuKey,
            onTap: () => _showMenu(context),
            child: Icon(Icons.menu, size: 14, color: theme.headerBarTextColor),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: SizedBox(
              height: 38,
              child: WindowTabBar(
                controller: widget.windowTabs,
                newTabLabel: 'New Window',
                style: TabBarStyle.fromFlutterLaneTheme(theme),
              ),
            ),
          ),
          const Spacer(),
          _LayoutDropdown(manager: widget.manager, onSelectLayout: widget.onSelectLayout),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.save_outlined, size: 15, color: theme.headerBarTextColor),
            tooltip: 'Save current layout',
            onPressed: () => _showSaveDialog(context, widget.manager),
          ),
          IconButton(
            icon: Icon(_themeIcon(widget.manager), size: 15, color: theme.headerBarTextColor),
            tooltip: _themeTooltip(widget.manager),
            onPressed: () => widget.manager.themeManager.cycleTheme(),
          ),
          IconButton(
            key: const ValueKey('reset-default-layout'),
            icon: Icon(Icons.restore, size: 15, color: theme.headerBarTextColor),
            tooltip: 'Reset to default layout',
            onPressed: () => widget.onResetLayout(),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final theme = widget.manager.currentTheme;
    final RenderBox? box = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);

    final items = <PopupMenuEntry<String>>[
      _buildPopupItem('new_file', 'New File', Icons.add, 'Ctrl+N'),
      _buildPopupItem('new_window', 'New Window', Icons.tab, 'Ctrl+Shift+N'),
      const PopupMenuDivider(),
      _buildPopupItem('open_file', 'Open File...', Icons.folder_open, 'Ctrl+O'),
      _buildPopupItem('open_folder', 'Open Folder...', Icons.folder, 'Ctrl+K O'),
      const PopupMenuDivider(),
      _buildPopupItem('save', 'Save', Icons.save_outlined, 'Ctrl+S'),
      _buildPopupItem('save_as', 'Save As...', Icons.save, 'Ctrl+Shift+S'),
      const PopupMenuDivider(),
      _buildPopupItem('preferences', 'Preferences', Icons.settings, ''),
      const PopupMenuDivider(),
      _buildPopupItem('undo', 'Undo', Icons.undo, 'Ctrl+Z'),
      _buildPopupItem('redo', 'Redo', Icons.redo, 'Ctrl+Y'),
      const PopupMenuDivider(),
      _buildPopupItem('cut', 'Cut', Icons.content_cut, 'Ctrl+X'),
      _buildPopupItem('copy', 'Copy', Icons.copy, 'Ctrl+C'),
      _buildPopupItem('paste', 'Paste', Icons.paste, 'Ctrl+V'),
      const PopupMenuDivider(),
      _buildPopupItem('find', 'Find', Icons.search, 'Ctrl+F'),
      _buildPopupItem('replace', 'Replace', Icons.find_replace, 'Ctrl+H'),
      const PopupMenuDivider(),
      _buildPopupItem('explorer', 'Explorer', Icons.folder_copy_rounded, 'Ctrl+Shift+E'),
      _buildPopupItem('terminal', 'Terminal', Icons.terminal, 'Ctrl+`'),
      _buildPopupItem('debug', 'Debug', Icons.bug_report, 'Ctrl+Shift+D'),
      const PopupMenuDivider(),
      _buildPopupItem('exit', 'Exit', Icons.exit_to_app, ''),
    ];

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx, offset.dy + box.size.height, offset.dx + 250, offset.dy + box.size.height + 400,
      ),
      items: items,
      color: theme.sectionBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: theme.sectionBorderColor),
      ),
      elevation: 8,
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'save':
          _showSaveDialog(context, widget.manager);
          break;
        case 'exit':
          windowManager.close();
          break;
      }
    });
  }

  PopupMenuItem<String> _buildPopupItem(String value, String label, IconData icon, String shortcut) {
    final theme = widget.manager.currentTheme;
    return PopupMenuItem(
      value: value,
      height: 32,
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.tabInactiveTextColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12, color: theme.sectionHeaderTextColor)),
          ),
          if (shortcut.isNotEmpty)
            Text(
              shortcut,
              style: TextStyle(fontSize: 11, color: theme.tabInactiveTextColor.withValues(alpha: 0.6)),
            ),
        ],
      ),
    );
  }
}

class _TrafficDot extends StatelessWidget {
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _TrafficDot({required this.color, required this.tooltip, required this.onTap});

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
// ActivityBar — folder_copy_rounded applies the active tab's layout
// ============================================================

class _ActivityBar extends StatelessWidget {
  final FlutterLaneManager manager;
  final String activeActivity;
  final ValueChanged<String> onActivityTap;

  const _ActivityBar({
    required this.manager,
    required this.activeActivity,
    required this.onActivityTap,
  });

  static const List<(String, IconData)> _items = [
    ('explorer', Icons.folder_copy_rounded),
    ('search', Icons.search_rounded),
    ('git', Icons.account_tree_rounded),
    ('terminal', Icons.terminal_rounded),
    ('debug', Icons.bug_report_rounded),
    ('chat', Icons.chat_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = manager.currentTheme;

    return Container(
      width: 48,
      color: theme.swimlaneBackground,
      child: Column(
        children: [
          const SizedBox(height: 12),
          ..._items.map((item) {
            final isSelected = item.$1 == activeActivity;
            return _ActivityIcon(
              icon: item.$2,
              selected: isSelected,
              theme: theme,
              onTap: () => onActivityTap(item.$1),
              tooltip: item.$1,
            );
          }),
          const Spacer(),
          GestureDetector(
            onTap: () => onActivityTap('settings'),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: 'settings' == activeActivity
                    ? theme.tabActiveBackground
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.settings_outlined,
                  size: 20, color: theme.tabInactiveTextColor),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _ActivityIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final FlutterLaneThemeData theme;
  final VoidCallback onTap;
  final String tooltip;

  const _ActivityIcon({
    required this.icon,
    required this.selected,
    required this.theme,
    required this.onTap,
    this.tooltip = '',
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: selected ? theme.tabActiveBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: selected ? theme.tabActiveTextColor : theme.tabInactiveTextColor,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Copilot
// ============================================================

class _CopilotPane extends StatelessWidget {
  final FlutterLaneManager manager;

  const _CopilotPane({required this.manager});

  @override
  Widget build(BuildContext context) {
    final theme = manager.currentTheme;

    return Container(
      color: theme.sectionBackground,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_fix_high_rounded,
                  size: 14, color: Colors.indigoAccent),
              const SizedBox(width: 6),
              Text(
                'Copilot',
                style: TextStyle(
                  color: theme.sectionHeaderTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.more_horiz,
                  size: 14, color: theme.tabInactiveTextColor),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.tabBarBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.tabBorderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask Copilot',
                    style: TextStyle(
                      color: theme.sectionHeaderTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PromptBubble(
                              'Generate a VS Code-inspired IDE shell for FlutterLane.'),
                          SizedBox(height: 6),
                          _PromptBubble(
                            'Add a Chrome-like header with tabs and workspace actions.',
                            accent: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.tabActiveBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.tabBorderColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.send_rounded,
                            size: 14, color: Colors.indigoAccent),
                        const SizedBox(width: 6),
                        Text(
                          'Ask a question...',
                          style: TextStyle(
                            color: theme.tabInactiveTextColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptBubble extends StatelessWidget {
  final String text;
  final bool accent;

  const _PromptBubble(this.text, {this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent ? Colors.indigo.withValues(alpha: 0.18) : Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.white70),
      ),
    );
  }
}

// ============================================================
// Dialogs & chrome helpers
// ============================================================

void _showSaveDialog(BuildContext context, FlutterLaneManager mgr) {
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
              mgr.saveAsNewLayout(controller.text);
            }
            Navigator.pop(ctx);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class _LayoutDropdown extends StatelessWidget {
  final FlutterLaneManager manager;
  final ValueChanged<String> onSelectLayout;

  const _LayoutDropdown({
    required this.manager,
    required this.onSelectLayout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = manager.currentTheme;
    final layouts = manager.layouts.where((l) => !l.isSystemDefault).toList();
    final activeId = manager.activeLayout?.snapshotId;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.sectionHeaderBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.sectionBorderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: activeId,
          isDense: true,
          style: TextStyle(fontSize: 11, color: theme.headerBarTextColor),
          items: layouts
              .map((l) => DropdownMenuItem(
                    value: l.snapshotId,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.layoutName),
                        if (l.isSystemDefault) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.lock_outline,
                              size: 10, color: theme.tabInactiveTextColor),
                        ],
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (id) {
            if (id != null) {
              onSelectLayout(id);
            }
          },
        ),
      ),
    );
  }
}

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

// ============================================================
// Workspace-aware views — same view type, per-workspace data
// ============================================================

class _EditorView extends StatelessWidget {
  final _Workspace workspace;
  final ValueNotifier<String> openFile;

  const _EditorView({required this.workspace, required this.openFile});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);
    final ws = workspace;

    return ValueListenableBuilder<String>(
      valueListenable: openFile,
      builder: (context, activeFile, _) {
        final lines = ws.contentOf(activeFile).trimRight().split('\n');
        return Container(
          color: theme.paneContentBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File tabs — per-workspace markdown files
              Container(
                height: 30,
                color: theme.tabBarBackground,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  children: [
                    for (final file in ws.files)
                      GestureDetector(
                        onTap: () => openFile.value = file.name,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: file.name == activeFile
                                ? theme.tabActiveBackground
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: file.name == activeFile
                                    ? theme.tabActiveTextColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.article_outlined,
                                  size: 12,
                                  color: file.name == activeFile
                                      ? theme.tabActiveTextColor
                                      : theme.tabInactiveTextColor),
                              const SizedBox(width: 4),
                              Text(
                                file.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: file.name == activeFile
                                      ? theme.tabActiveTextColor
                                      : theme.tabInactiveTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  itemCount: lines.length,
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    final isHeader = line.startsWith('#');
                    return Text(
                      '${(index + 1).toString().padLeft(2)}  $line',
                      style: TextStyle(
                        color: isHeader
                            ? theme.tabActiveTextColor
                            : theme.sectionHeaderTextColor
                                .withValues(alpha: .85),
                        fontWeight:
                            isHeader ? FontWeight.w600 : FontWeight.w400,
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.65,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExplorerView extends StatelessWidget {
  final _Workspace workspace;
  final ValueNotifier<String> openFile;
  final ValueChanged<String> onOpenFile;

  const _ExplorerView({
    required this.workspace,
    required this.openFile,
    required this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              workspace.title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          for (final node in workspace.tree) _buildNode(node),
        ],
      ),
    );
  }

  /// Resolves the workspace file a tree leaf opens. Tree leaves display a
  /// short basename while workspace files may be nested paths
  /// (e.g. 'docs/index.md'), so match by exact name or trailing '/basename'.
  String? _fileNameFor(_TreeNode node) {
    if (node.isFolder) return null;
    for (final f in workspace.files) {
      if (f.name == node.name ||
          f.name.endsWith('/${node.name}')) {
        return f.name;
      }
    }
    return null;
  }

  Widget _buildNode(_TreeNode node) {
    if (node.isFolder) {
      return ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: true,
        title: Row(
          children: [
            Icon(Icons.folder_outlined, size: 14, color: Colors.amber[700]),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                node.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        children: [for (final child in node.children) _buildNode(child)],
      );
    }

    final isMarkdown = node.name.endsWith('.md');
    final fileName = _fileNameFor(node);
    return ValueListenableBuilder<String>(
      valueListenable: openFile,
      builder: (context, activeFile, _) {
        final isActive = activeFile == fileName;
        return InkWell(
          onTap: fileName != null ? () => onOpenFile(fileName) : null,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, top: 2, bottom: 2),
            child: Row(
              children: [
                Icon(
                  isMarkdown
                      ? Icons.article_outlined
                      : Icons.insert_drive_file_outlined,
                  size: 14,
                  color: isActive
                      ? Colors.lightBlue
                      : isMarkdown
                          ? Colors.lightBlue[300]
                          : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    node.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive
                          ? Colors.lightBlue
                          : Colors.grey[200],
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (fileName != null)
                  Icon(
                    Icons.open_in_new,
                    size: 11,
                    color: Colors.grey[700],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MarkdownPreviewView extends StatelessWidget {
  final _Workspace workspace;
  final ValueNotifier<String> openFile;

  const _MarkdownPreviewView({
    required this.workspace,
    required this.openFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);

    return ValueListenableBuilder<String>(
      valueListenable: openFile,
      builder: (context, activeFile, _) {
        final lines =
            workspace.contentOf(activeFile).trimRight().split('\n');
        return Container(
          color: theme.paneContentBackground,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in lines)
                  if (line.startsWith('### '))
                    _previewLine(line.substring(4),
                        theme.sectionHeaderTextColor, 13)
                  else if (line.startsWith('## '))
                    _previewLine(line.substring(3), theme.tabActiveTextColor, 15)
                  else if (line.startsWith('# '))
                    _previewLine(line.substring(2), theme.tabActiveTextColor, 18)
                  else if (line.startsWith('- '))
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('•  ',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: theme.tabInactiveTextColor)),
                          Expanded(
                            child: Text(line.substring(2),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: theme.sectionHeaderTextColor
                                        .withValues(alpha: .85))),
                          ),
                        ],
                      ),
                    )
                  else if (line.trim().isEmpty)
                    const SizedBox(height: 8)
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(line,
                          style: TextStyle(
                              fontSize: 12,
                              color: theme.sectionHeaderTextColor
                                  .withValues(alpha: .85))),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _previewLine(String text, Color color, double size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search files...',
              isDense: true,
              prefixIcon: const Icon(Icons.search, size: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
            ),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Type to search across all files',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _TerminalView extends StatelessWidget {
  final _Workspace workspace;

  const _TerminalView({required this.workspace});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$ flutterlane ${workspace.id}',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Color(0xFF4EC9B0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Working on ${workspace.title} (${workspace.url})...',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Color(0xFF569CD6),
            ),
          ),
          const Text(
            '\$ _',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Color(0xFFCCCCCC),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutputView extends StatelessWidget {
  const _OutputView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(8),
      child: const Text(
        'Output panel — build logs and runtime output will appear here.\n\n'
        'Drag this tab to another section to relocate it.',
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}

class _ProblemsView extends StatelessWidget {
  const _ProblemsView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No problems detected',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Drag & drop panes between sections to reorganize.\n'
            'Drag section headers across swimlanes to move them.\n'
            'Use the hover zone on the right edge to add swimlanes.',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _DebugConsoleView extends StatelessWidget {
  const _DebugConsoleView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(8),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug session started',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Color(0xFF4EC9B0),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Debugger attached to process',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Color(0xFFCCCCCC),
            ),
          ),
          Text(
            'Breakpoints: 3 set',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Color(0xFF569CD6),
            ),
          ),
          Text(
            '\$ _',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Color(0xFFCCCCCC),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortsView extends StatelessWidget {
  const _PortsView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Forwarded Ports',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _portRow('3000', 'Flutter Web', true),
          _portRow('8080', 'API Server', false),
          _portRow('5000', 'Firebase', false),
        ],
      ),
    );
  }

  Widget _portRow(String port, String label, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            active ? Icons.play_circle : Icons.pause_circle,
            size: 14,
            color: active ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            port,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Git (Source Control) view
// ============================================================

class _GitView extends StatelessWidget {
  final _Workspace workspace;
  const _GitView({required this.workspace});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);

    return Container(
      color: theme.sectionBackground,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree_outlined,
                  size: 14, color: Colors.tealAccent),
              const SizedBox(width: 6),
              Text(
                'Source Control',
                style: TextStyle(
                  color: theme.sectionHeaderTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.refresh,
                  size: 14, color: theme.tabInactiveTextColor),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.tabBarBackground,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.tabBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Changes (3)',
                  style: TextStyle(
                    color: theme.sectionHeaderTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _gitChangeRow('M', 'lib/src/core/flutter_lane_manager.dart',
                    Colors.orange),
                _gitChangeRow('A', 'lib/src/interactions/hot_zone.dart',
                    Colors.green),
                _gitChangeRow('D', 'lib/src/legacy/old_api.dart', Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: theme.tabActiveBackground,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.tabBorderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.commit, size: 14, color: theme.tabActiveTextColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Commit Message',
                    style: TextStyle(
                      color: theme.tabInactiveTextColor,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.tabActiveBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Commit',
                    style: TextStyle(
                      color: theme.tabActiveTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Branch: master',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: theme.tabInactiveTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gitChangeRow(String letter, String file, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              letter,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              file,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Settings view
// ============================================================

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  bool _autoSave = true;
  bool _minimap = true;
  bool _wordWrap = false;
  int _fontSize = 14;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);

    return Container(
      color: theme.sectionBackground,
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editor Settings',
              style: TextStyle(
                color: theme.sectionHeaderTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _settingToggle(
                'Auto Save', _autoSave, (v) => setState(() => _autoSave = v), theme),
            _settingToggle(
                'Minimap', _minimap, (v) => setState(() => _minimap = v), theme),
            _settingToggle(
                'Word Wrap', _wordWrap, (v) => setState(() => _wordWrap = v), theme),
            const SizedBox(height: 12),
            Text(
              'Font Size',
              style: TextStyle(
                color: theme.sectionHeaderTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _fontSizeBtn('-', theme),
                const SizedBox(width: 8),
                Text(
                  '$_fontSize',
                  style: TextStyle(
                    color: theme.tabActiveTextColor,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                _fontSizeBtn('+', theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingToggle(
      String label, bool value, ValueChanged<bool> onChanged, FlutterLaneThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.sectionHeaderTextColor,
                fontSize: 11,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 32,
              height: 18,
              decoration: BoxDecoration(
                color: value ? Colors.tealAccent.withValues(alpha: 0.3) : theme.tabBarBackground,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: theme.tabBorderColor),
              ),
              child: Align(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: value ? Colors.tealAccent : theme.tabInactiveTextColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fontSizeBtn(String op, FlutterLaneThemeData theme) {
    return GestureDetector(
      onTap: () => setState(() {
        _fontSize = (op == '+')
            ? (_fontSize + 1).clamp(10, 24)
            : (_fontSize - 1).clamp(10, 24);
      }),
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.tabBarBackground,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.tabBorderColor),
        ),
        child: Text(
          op,
          style: TextStyle(
            color: theme.tabActiveTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}