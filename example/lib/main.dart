import 'package:flutter/material.dart';
import 'package:flutterlane/flutterlane.dart';

void main() => runApp(const FlutterLaneExampleApp());

class FlutterLaneExampleApp extends StatefulWidget {
  const FlutterLaneExampleApp({super.key});

  @override
  State<FlutterLaneExampleApp> createState() => _FlutterLaneExampleAppState();
}

class _FlutterLaneExampleAppState extends State<FlutterLaneExampleApp> {
  final FlutterLaneManager _manager = FlutterLaneManager();
  final TabBarController _windowTabs = TabBarController(
    initialTabs: const [
      TabData(title: 'FlutterLane', url: 'flutterlane.dev', closable: false),
      TabData(title: 'Design Docs', url: 'docs.flutterlane.dev'),
      TabData(title: 'GitHub', url: 'github.com/flutterlane'),
    ],
  );
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _manager.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'explorer',
      viewDisplayName: 'Explorer',
      icon: Icons.folder_outlined,
      isSystemBuiltIn: true,
      viewBuilder: (ctx, bizCtx, state) => const _ExplorerView(),
    ));

    _manager.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'search',
      viewDisplayName: 'Search',
      icon: Icons.search,
      viewBuilder: (ctx, bizCtx, state) => const _SearchView(),
    ));

    _manager.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'terminal',
      viewDisplayName: 'Terminal',
      icon: Icons.terminal,
      viewBuilder: (ctx, bizCtx, state) => const _TerminalView(),
    ));

    _manager.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'output',
      viewDisplayName: 'Output',
      icon: Icons.output,
      viewBuilder: (ctx, bizCtx, state) => const _OutputView(),
    ));

    _manager.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'problems',
      viewDisplayName: 'Problems',
      icon: Icons.error_outline,
      viewBuilder: (ctx, bizCtx, state) => const _ProblemsView(),
    ));

    _manager.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'activitybar',
      viewDisplayName: 'Activity Bar',
      icon: Icons.apps,
      viewBuilder: (ctx, bizCtx, state) => _ActivityBar(manager: _manager),
    ));
    _manager.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'editor',
      viewDisplayName: 'Editor',
      icon: Icons.code,
      viewBuilder: (ctx, bizCtx, state) => const _EditorView(),
    ));
    _manager.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'copilot',
      viewDisplayName: 'Copilot',
      icon: Icons.auto_fix_high,
      viewBuilder: (ctx, bizCtx, state) => _CopilotPane(manager: _manager),
    ));

    await _manager.init();
    await _manager.themeManager.setTheme(FlutterLaneThemeType.dark);

    final active = _manager.activeLayout;
    final hasActivityBar = active?.swimlanes.any(
          (lane) => lane.sections.any(
            (section) => section.panes.any(
              (pane) => pane.viewInstance.viewTypeId == 'activitybar',
            ),
          ),
        ) ??
        false;
    if (active != null && !hasActivityBar) {
      active.swimlanes
        ..clear()
        ..addAll([
          _demoSwimlane(0.12, '', 'activitybar', fixedWidth: 64),
          _demoSwimlane(0.23, 'Explorer', 'explorer'),
          _demoSwimlane(0.43, 'main.dart', 'editor'),
          _demoSwimlane(0.22, 'Copilot', 'copilot'),
        ]);
      await _manager.save();
    }

    setState(() => _ready = true);
  }

  Swimlane _demoSwimlane(
    double flex,
    String title,
    String viewTypeId, {
    double? fixedWidth,
  }) {
    final section = Section(
      title: title,
      canToggle: fixedWidth == null,
      canAddPane: fixedWidth == null,
    );
    section.addPane(Pane(
      paneId: generateId(),
      viewInstance: ViewInstance(viewTypeId: viewTypeId),
    ));
    return Swimlane(
      flex: flex,
      minWidth: fixedWidth ?? 120,
      fixedWidth: fixedWidth,
      canClose: fixedWidth == null,
      sections: [section],
    );
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
        final isDark =
            _manager.themeManager.currentType == FlutterLaneThemeType.dark;

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
                  isDark: isDark,
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
}

class _ChromeHeader extends StatelessWidget {
  final FlutterLaneManager manager;
  final TabBarController windowTabs;
  final bool isDark;

  const _ChromeHeader({
    required this.manager,
    required this.windowTabs,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = manager.currentTheme;

    return Container(
      height: 42,
      color: theme.headerBarBackground,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Row(
            children: const [
              _TrafficButton(color: Color(0xFFff5f57)),
              SizedBox(width: 8),
              _TrafficButton(color: Color(0xFFfebc2e)),
              SizedBox(width: 8),
              _TrafficButton(color: Color(0xFF28c840)),
            ],
          ),
          const SizedBox(width: 16),
          Icon(Icons.menu, size: 14, color: theme.headerBarTextColor),
          const SizedBox(width: 12),
          SizedBox(
            width: 380,
            height: 38,
            child: WindowTabBar(
              controller: windowTabs,
              newTabLabel: 'New Window',
            ),
          ),
          const Spacer(),
          _LayoutDropdown(manager: manager),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.save_outlined,
                size: 15, color: theme.headerBarTextColor),
            tooltip: 'Save current layout',
            onPressed: () => _showSaveDialog(context, manager),
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              size: 15,
              color: theme.headerBarTextColor,
            ),
            tooltip: 'Toggle theme',
            onPressed: () => manager.themeManager.setTheme(
              isDark ? FlutterLaneThemeType.light : FlutterLaneThemeType.dark,
            ),
          ),
          IconButton(
            key: const ValueKey('reset-default-layout'),
            icon:
                Icon(Icons.restore, size: 15, color: theme.headerBarTextColor),
            tooltip: 'Reset to default layout',
            onPressed: () => manager.resetToDefault(),
          ),
        ],
      ),
    );
  }
}

class _TrafficButton extends StatelessWidget {
  final Color color;
  const _TrafficButton({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _HeaderTab extends StatelessWidget {
  final String label;
  final bool selected;

  const _HeaderTab(this.label, {required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.white54;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _ActivityBar extends StatelessWidget {
  final FlutterLaneManager manager;

  const _ActivityBar({required this.manager});

  @override
  Widget build(BuildContext context) {
    final theme = manager.currentTheme;
    const icons = [
      Icons.folder_copy_rounded,
      Icons.search_rounded,
      Icons.terminal_rounded,
      Icons.bug_report_rounded,
      Icons.chat_rounded,
    ];

    return Container(
      width: 58,
      color: theme.swimlaneBackground,
      child: Column(
        children: [
          const SizedBox(height: 12),
          ...icons.map((icon) {
            final isSelected = icon == Icons.folder_copy_rounded;
            return Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color:
                    isSelected ? theme.tabActiveBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: theme.tabActiveTextColor),
            );
          }),
          const Spacer(),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.settings_outlined,
                size: 18, color: theme.tabInactiveTextColor),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _ExplorerPane extends StatelessWidget {
  final FlutterLaneManager manager;

  const _ExplorerPane({required this.manager});

  @override
  Widget build(BuildContext context) {
    final theme = manager.currentTheme;

    return Container(
      color: theme.sectionBackground,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Explorer',
                style: TextStyle(
                  color: theme.sectionHeaderTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, size: 14, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 10),
          const _FolderRow('flutterlane', Icons.folder_open_rounded, true),
          const _FolderRow('lib', Icons.folder_open_rounded, false),
          const _FolderRow('src', Icons.folder_open_rounded, false),
          const _FolderRow('example', Icons.folder_open_rounded, false),
          const _FolderRow('docs', Icons.folder_open_rounded, false),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.tabBarBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.developer_board,
                    size: 14, color: theme.tabActiveTextColor),
                const SizedBox(width: 8),
                Text(
                  'Open editors',
                  style: TextStyle(
                    color: theme.tabActiveTextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool root;

  const _FolderRow(this.label, this.icon, this.root);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.amberAccent),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          if (root) const Spacer(),
        ],
      ),
    );
  }
}

class _CopilotPane extends StatelessWidget {
  final FlutterLaneManager manager;

  const _CopilotPane({required this.manager});

  @override
  Widget build(BuildContext context) {
    final theme = manager.currentTheme;

    return Container(
      color: theme.sectionBackground,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_fix_high_rounded,
                  size: 14, color: Colors.indigoAccent),
              const SizedBox(width: 8),
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
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.tabBarBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.tabBorderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask Copilot',
                    style: TextStyle(
                      color: theme.sectionHeaderTextColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _PromptBubble(
                      'Generate a VS Code-inspired IDE shell for FlutterLane.'),
                  const SizedBox(height: 8),
                  const _PromptBubble(
                    'Add a Chrome-like header with tabs and workspace actions.',
                    accent: true,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.tabActiveBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.tabBorderColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.send_rounded,
                            size: 14, color: Colors.indigoAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Ask a question...',
                          style: TextStyle(
                            color: theme.tabInactiveTextColor,
                            fontSize: 12,
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

  const _LayoutDropdown({required this.manager});

  @override
  Widget build(BuildContext context) {
    final theme = manager.currentTheme;
    final layouts = manager.layouts;
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
              manager.switchLayout(id);
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

class _EditorView extends StatelessWidget {
  const _EditorView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const lines = [
      'import \'package:flutterlane/flutterlane.dart\';',
      '',
      'class Workspace extends StatelessWidget {',
      '  const Workspace({super.key});',
      '',
      '  @override',
      '  Widget build(BuildContext context) {',
      '    return FlutterLaneWorkbench(manager: manager);',
      '  }',
      '}',
    ];
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(24, 18, 16, 12),
      child: ListView.builder(
        itemCount: lines.length,
        itemBuilder: (context, index) => Text(
          '${(index + 1).toString().padLeft(2)}  ${lines[index]}',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: .82),
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.65,
          ),
        ),
      ),
    );
  }
}

class _ExplorerView extends StatelessWidget {
  const _ExplorerView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _treeTile('src', [
            _treeTile('core', [
              _treeItem('flutter_lane_manager.dart'),
            ]),
            _treeTile('models', [
              _treeItem('swimlane.dart'),
              _treeItem('section.dart'),
              _treeItem('pane.dart'),
              _treeItem('layout_state.dart'),
            ]),
            _treeTile('widgets', [
              _treeItem('workbench.dart'),
            ]),
          ]),
          _treeTile('example', [
            _treeItem('main.dart'),
          ]),
          _treeItem('pubspec.yaml'),
        ],
      ),
    );
  }

  Widget _treeItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 2),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file_outlined,
              size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _treeTile(String name, List<Widget> children) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Icon(Icons.folder_outlined, size: 14, color: Colors.amber[700]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      children: children,
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
  const _TerminalView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(8),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$ flutterlane build',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Color(0xFF4EC9B0),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Building FlutterLane project...',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Color(0xFFCCCCCC),
            ),
          ),
          Text(
            '✓ 0 issues found',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Color(0xFF4EC9B0),
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
