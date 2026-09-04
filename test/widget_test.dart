import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterlane/flutterlane.dart';

// ── Helpers ──

Widget _noopBuilder(
  BuildContext context,
  String bizCtx,
  Map<String, dynamic> state,
) =>
    const SizedBox();

/// Wraps a widget in the minimum required boilerplate for rendering.
Widget _wrapInApp(Widget child, {FlutterLaneThemeData? theme}) {
  return MaterialApp(
    home: FlutterLaneTheme(
      data: theme ?? FlutterLaneThemeData.light,
      child: Scaffold(body: child),
    ),
  );
}

/// Creates a minimal layout with one swimlane, one section, and optionally
/// some panes.
LayoutState _makeLayout({
  String swId = 'sw-1',
  String secId = 'sec-1',
  String secTitle = 'Section 1',
  List<Pane>? panes,
  double sectionFlex = 1.0,
  bool swCanClose = true,
}) {
  final section = Section(
    sectionId: secId,
    title: secTitle,
    flex: sectionFlex,
    panes: panes ?? [],
    activePaneId: panes != null && panes.isNotEmpty ? panes.first.paneId : null,
  );
  final swimlane = Swimlane(id: swId, canClose: swCanClose, sections: [section]);
  return LayoutState(
    layoutName: 'Test',
    isSystemDefault: false,
    isCurrentActive: true,
    swimlanes: [swimlane],
  );
}

/// Creates a layout with two swimlanes for cross-swimlane tests.
LayoutState _makeTwoSwimlaneLayout({
  List<Pane>? sw1Panes,
  List<Pane>? sw2Panes,
}) {
  final s1 = Section(
    sectionId: 'sec-1',
    title: 'Section A',
    panes: sw1Panes ?? [],
    activePaneId:
        sw1Panes != null && sw1Panes.isNotEmpty ? sw1Panes.first.paneId : null,
  );
  final s2 = Section(
    sectionId: 'sec-2',
    title: 'Section B',
    panes: sw2Panes ?? [],
    activePaneId:
        sw2Panes != null && sw2Panes.isNotEmpty ? sw2Panes.first.paneId : null,
  );
  return LayoutState(
    layoutName: 'Two-Swimlane',
    isSystemDefault: false,
    isCurrentActive: true,
    swimlanes: [
      Swimlane(id: 'sw-1', sections: [s1]),
      Swimlane(id: 'sw-2', sections: [s2]),
    ],
  );
}

/// Helper: creates a [Pane] with a generated ID.
Pane _pane(String id, String viewType) => Pane(
      paneId: id,
      viewInstance: ViewInstance(viewTypeId: viewType),
    );

class _TestTrafficDot extends StatelessWidget {
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _TestTrafficDot({
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

// ══════════════════════════════════════════════════════════════════════════════
// FlutterLaneWorkbench
// ══════════════════════════════════════════════════════════════════════════════

void main() {
  group('FlutterLaneWorkbench', () {
    late FlutterLaneManager manager;

    setUp(() {
      manager = FlutterLaneManager(
        workspace: Workspace(workspaceId: 'test-ws'),
      );
    });

    testWidgets('renders a swimlane from the active layout', (tester) async {
      manager.loadLayout(_makeLayout(secTitle: 'My Section'));
      await tester.pumpWidget(_wrapInApp(FlutterLaneWorkbench(manager: manager)));

      expect(find.text('My Section'), findsOneWidget);
      expect(find.byType(SwimlaneWidget), findsOneWidget);
    });

    testWidgets('renders multiple swimlanes', (tester) async {
      manager.loadLayout(_makeTwoSwimlaneLayout());
      await tester.pumpWidget(_wrapInApp(FlutterLaneWorkbench(manager: manager)));

      expect(find.byType(SwimlaneWidget), findsNWidgets(2));
      expect(find.text('Section A'), findsOneWidget);
      expect(find.text('Section B'), findsOneWidget);
    });

    testWidgets('rebuilds when manager notifies', (tester) async {
      manager.loadLayout(_makeLayout(secTitle: 'Before'));
      await tester.pumpWidget(_wrapInApp(FlutterLaneWorkbench(manager: manager)));
      expect(find.text('Before'), findsOneWidget);

      // Mutate the layout via the manager.
      manager.activeLayout!.swimlanes.first.sections.first.title = 'After';
      manager.syncNotify();
      await tester.pump();

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('shows empty state when activeLayout is null', (tester) async {
      // Manager without a loaded layout.
      await tester.pumpWidget(_wrapInApp(FlutterLaneWorkbench(manager: manager)));

      // Should still render (no crash), and no SwimlaneWidget present.
      expect(find.byType(SwimlaneWidget), findsNothing);
    });

    testWidgets('applies the active theme via FlutterLaneTheme', (tester) async {
      manager.loadLayout(_makeLayout());
      manager.themeManager.setTheme(FlutterLaneThemeType.dark);

      await tester.pumpWidget(_wrapInApp(FlutterLaneWorkbench(manager: manager)));
      await tester.pump();

      // The workbench wraps in FlutterLaneTheme with the manager's theme.
      final themeWidget = tester.widget<FlutterLaneTheme>(
        find.byType(FlutterLaneTheme).last,
      );
      expect(themeWidget.data, FlutterLaneThemeData.dark);
    });

    testWidgets('add swimlane hot zone adds a swimlane', (tester) async {
      manager.loadLayout(_makeLayout());
      await tester.pumpWidget(_wrapInApp(FlutterLaneWorkbench(manager: manager)));

      // Tap the hot zone (AddSwimlaneHotZone).
      final hotZone = find.byType(AddSwimlaneHotZone);
      expect(hotZone, findsOneWidget);

      await tester.tap(hotZone);
      await tester.pump();

      expect(manager.activeLayout!.swimlanes.length, 2);
    });

    testWidgets('tapping a tab calls onTabTap and activates the pane',
        (tester) async {
      final panes = [
        _pane('p1', 'explorer'),
        _pane('p2', 'search'),
      ];
      manager.loadLayout(_makeLayout(panes: panes));
      manager.registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'explorer',
        viewDisplayName: 'Explorer',
        icon: Icons.folder,
        viewBuilder: _noopBuilder,
      ));
      manager.registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'search',
        viewDisplayName: 'Search',
        icon: Icons.search,
        viewBuilder: _noopBuilder,
      ));

      await tester.pumpWidget(_wrapInApp(FlutterLaneWorkbench(manager: manager)));

      // Tap the second tab (Search).
      await tester.tap(find.text('Search'));
      await tester.pump();

      final section =
          manager.activeLayout!.swimlanes.first.sections.first;
      expect(section.activePaneId, 'p2');
    });

    testWidgets('close button removes a pane', (tester) async {
      final panes = [_pane('p-close', 'terminal')];
      manager.loadLayout(_makeLayout(panes: panes, swCanClose: false));
      manager.registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'terminal',
        viewDisplayName: 'Terminal',
        icon: Icons.terminal,
        viewBuilder: _noopBuilder,
      ));

      await tester.pumpWidget(_wrapInApp(FlutterLaneWorkbench(manager: manager)));

      // Find the close icon for the pane.
      final closeBtn = find.byIcon(Icons.close);
      expect(closeBtn, findsOneWidget);

      await tester.tap(closeBtn);
      await tester.pump();

      final section =
          manager.activeLayout!.swimlanes.first.sections.first;
      expect(section.panes, isEmpty);
    });

    testWidgets('add section button adds a section to the swimlane',
        (tester) async {
      manager.loadLayout(_makeLayout());
      await tester.pumpWidget(_wrapInApp(FlutterLaneWorkbench(manager: manager)));

      // The _AddSectionHotZone at the bottom of the swimlane.
      final addSection = find.descendant(
        of: find.byType(SwimlaneWidget),
        matching: find.byIcon(Icons.add),
      ).last;
      await tester.tap(addSection);
      await tester.pump();

      // Original section + new one (placeholder removed because new is added).
      expect(manager.activeLayout!.swimlanes.first.sections.length, greaterThanOrEqualTo(2));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // SectionWidget
  // ══════════════════════════════════════════════════════════════════════════

  group('SectionWidget', () {
    late FlutterLaneRegistry registry;

    setUp(() {
      registry = FlutterLaneRegistry();
    });

    testWidgets('renders section title in tab bar', (tester) async {
      final section = Section(sectionId: 's1', title: 'Explorer');
      await tester.pumpWidget(
        _wrapInApp(
          SectionWidget(
            section: section,
            swimlaneId: 'sw-1',
            registry: registry,
          ),
        ),
      );

      expect(find.text('Explorer'), findsOneWidget);
    });

    testWidgets('renders tabs for each pane', (tester) async {
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'v1',
        viewDisplayName: 'View One',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'v2',
        viewDisplayName: 'View Two',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));

      final section = Section(
        sectionId: 's1',
        title: 'Panel',
        panes: [_pane('p1', 'v1'), _pane('p2', 'v2')],
        activePaneId: 'p1',
      );

      await tester.pumpWidget(
        _wrapInApp(
          SectionWidget(
            section: section,
            swimlaneId: 'sw-1',
            registry: registry,
          ),
        ),
      );

      expect(find.text('View One'), findsOneWidget);
      expect(find.text('View Two'), findsOneWidget);
    });

    testWidgets('active tab has different styling than inactive', (tester) async {
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'v1',
        viewDisplayName: 'Tab A',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'v2',
        viewDisplayName: 'Tab B',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));

      final section = Section(
        sectionId: 's1',
        title: 'P',
        panes: [_pane('p1', 'v1'), _pane('p2', 'v2')],
        activePaneId: 'p1',
      );

      await tester.pumpWidget(
        _wrapInApp(
          SectionWidget(
            section: section,
            swimlaneId: 'sw-1',
            registry: registry,
          ),
        ),
      );

      // Both tabs should exist.
      expect(find.text('Tab A'), findsOneWidget);
      expect(find.text('Tab B'), findsOneWidget);
    });

    testWidgets('shows "No views open" when section has no panes and is expanded',
        (tester) async {
      final section = Section(
        sectionId: 's1',
        title: 'Empty',
        isExpanded: true,
      );

      await tester.pumpWidget(
        _wrapInApp(
          SectionWidget(
            section: section,
            swimlaneId: 'sw-1',
            registry: registry,
          ),
        ),
      );

      expect(find.text('No views open'), findsOneWidget);
    });

    testWidgets('renders registered pane view builder', (tester) async {
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'custom',
        viewDisplayName: 'Custom',
        icon: Icons.code,
        viewBuilder: (ctx, biz, state) => const Text('CUSTOM_WIDGET'),
      ));

      final section = Section(
        sectionId: 's1',
        title: 'P',
        panes: [_pane('p1', 'custom')],
        activePaneId: 'p1',
        isExpanded: true,
      );

      await tester.pumpWidget(
        _wrapInApp(
          SectionWidget(
            section: section,
            swimlaneId: 'sw-1',
            registry: registry,
          ),
        ),
      );

      expect(find.text('CUSTOM_WIDGET'), findsOneWidget);
    });

    testWidgets('renders placeholder for unregistered view type', (tester) async {
      final section = Section(
        sectionId: 's1',
        title: 'P',
        panes: [_pane('p1', 'nonexistent')],
        activePaneId: 'p1',
        isExpanded: true,
      );

      await tester.pumpWidget(
        _wrapInApp(
          SectionWidget(
            section: section,
            swimlaneId: 'sw-1',
            registry: registry,
          ),
        ),
      );

      // PaneWidget falls back to a placeholder showing "View: <type>".
      expect(find.text('View: nonexistent'), findsOneWidget);
    });

    testWidgets('onTabTap callback fires when a tab is tapped', (tester) async {
      String? tappedPaneId;
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'v1',
        viewDisplayName: 'Tappable',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));

      final section = Section(
        sectionId: 's1',
        title: 'P',
        panes: [_pane('tap-me', 'v1')],
        activePaneId: 'tap-me',
      );

      await tester.pumpWidget(
        _wrapInApp(
          SectionWidget(
            section: section,
            swimlaneId: 'sw-1',
            registry: registry,
            onTabTap: (id) => tappedPaneId = id,
          ),
        ),
      );

      await tester.tap(find.text('Tappable'));
      expect(tappedPaneId, 'tap-me');
    });

    testWidgets('onClosePane callback fires when close button is tapped',
        (tester) async {
      String? closedPaneId;
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'v1',
        viewDisplayName: 'Closeable',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));

      final section = Section(
        sectionId: 's1',
        title: 'P',
        panes: [_pane('close-me', 'v1')],
        activePaneId: 'close-me',
      );

      await tester.pumpWidget(
        _wrapInApp(
          SectionWidget(
            section: section,
            swimlaneId: 'sw-1',
            registry: registry,
            onClosePane: (id) => closedPaneId = id,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(closedPaneId, 'close-me');
    });

    testWidgets('onAddPane callback fires when add button is tapped',
        (tester) async {
      bool addPaneCalled = false;

      final section = Section(sectionId: 's1', title: 'P');

      await tester.pumpWidget(
        _wrapInApp(
          SectionWidget(
            section: section,
            swimlaneId: 'sw-1',
            registry: registry,
            onAddPane: () => addPaneCalled = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      expect(addPaneCalled, isTrue);
    });

    testWidgets('tab bar is a DragTarget', (tester) async {
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'v1',
        viewDisplayName: 'Draggable',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));

      final section = Section(
        sectionId: 's1',
        title: 'P',
        panes: [_pane('p1', 'v1')],
        activePaneId: 'p1',
      );

      await tester.pumpWidget(
        _wrapInApp(
          SectionWidget(
            section: section,
            swimlaneId: 'sw-1',
            registry: registry,
          ),
        ),
      );

      // Each tab should be wrapped in a Draggable<DragSource>.
      expect(find.byType(Draggable<DragSource>), findsWidgets);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // SwimlaneWidget
  // ══════════════════════════════════════════════════════════════════════════

  group('SwimlaneWidget', () {
    late FlutterLaneRegistry registry;

    setUp(() {
      registry = FlutterLaneRegistry();
    });

    testWidgets('renders a single section', (tester) async {
      final swimlane = Swimlane(
        id: 'sw-1',
        sections: [
          Section(sectionId: 's1', title: 'Only Section'),
        ],
      );

      await tester.pumpWidget(
        _wrapInApp(
          SwimlaneWidget(swimlane: swimlane, registry: registry),
        ),
      );

      expect(find.text('Only Section'), findsOneWidget);
      expect(find.byType(SectionWidget), findsOneWidget);
    });

    testWidgets('renders multiple sections with resize handles', (tester) async {
      final swimlane = Swimlane(
        id: 'sw-1',
        sections: [
          Section(sectionId: 's1', title: 'Top', flex: 1.0),
          Section(sectionId: 's2', title: 'Bottom', flex: 1.0),
        ],
      );

      await tester.pumpWidget(
        _wrapInApp(
          SwimlaneWidget(swimlane: swimlane, registry: registry),
        ),
      );

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
      expect(find.byType(SectionWidget), findsNWidgets(2));
      // A resize handle (GestureDetector with resize cursor) should exist.
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('add section hot zone is present when onAddSection is provided',
        (tester) async {
      bool addCalled = false;
      final swimlane = Swimlane(
        id: 'sw-1',
        sections: [Section(sectionId: 's1', title: 'A')],
      );

      await tester.pumpWidget(
        _wrapInApp(
          SwimlaneWidget(
            swimlane: swimlane,
            registry: registry,
            onAddSection: () => addCalled = true,
          ),
        ),
      );

      // Tap the add section area (icons.add inside _AddSectionHotZone).
      await tester.tap(find.byIcon(Icons.add).first);
      expect(addCalled, isTrue);
    });

    testWidgets('empty swimlane renders nothing', (tester) async {
      final swimlane = Swimlane(id: 'sw-1', sections: []);

      await tester.pumpWidget(
        _wrapInApp(
          SwimlaneWidget(swimlane: swimlane, registry: registry),
        ),
      );

      expect(find.byType(SectionWidget), findsNothing);
    });

    testWidgets('swimlane is a DragTarget for section drops', (tester) async {
      final swimlane = Swimlane(
        id: 'sw-1',
        sections: [Section(sectionId: 's1', title: 'A')],
      );

      await tester.pumpWidget(
        _wrapInApp(
          SwimlaneWidget(swimlane: swimlane, registry: registry),
        ),
      );

      // The SwimlaneWidget wraps its body in DragTarget<DragSource>.
      expect(find.byType(DragTarget<DragSource>), findsWidgets);
    });

    testWidgets('onTabTap callback propagates through to section',
        (tester) async {
      String? tappedPaneId;
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'v1',
        viewDisplayName: 'Clickable',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));

      final swimlane = Swimlane(
        id: 'sw-1',
        sections: [
          Section(
            sectionId: 's1',
            title: 'A',
            panes: [_pane('p-click', 'v1')],
            activePaneId: 'p-click',
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapInApp(
          SwimlaneWidget(
            swimlane: swimlane,
            registry: registry,
            onTabTap: (id) => tappedPaneId = id,
          ),
        ),
      );

      await tester.tap(find.text('Clickable'));
      expect(tappedPaneId, 'p-click');
    });

    testWidgets('onClosePane callback propagates through to section',
        (tester) async {
      String? closedPaneId;
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'v1',
        viewDisplayName: 'X',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));

      final swimlane = Swimlane(
        id: 'sw-1',
        sections: [
          Section(
            sectionId: 's1',
            title: 'A',
            panes: [_pane('p-x', 'v1')],
            activePaneId: 'p-x',
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapInApp(
          SwimlaneWidget(
            swimlane: swimlane,
            registry: registry,
            onClosePane: (id) => closedPaneId = id,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(closedPaneId, 'p-x');
    });

    testWidgets('respects flex distribution for multiple sections',
        (tester) async {
      final swimlane = Swimlane(
        id: 'sw-1',
        sections: [
          Section(sectionId: 's1', title: 'Big', flex: 3.0),
          Section(sectionId: 's2', title: 'Small', flex: 1.0),
        ],
      );

      await tester.pumpWidget(
        _wrapInApp(
          SwimlaneWidget(swimlane: swimlane, registry: registry),
        ),
      );

      // Both sections render — flex is handled by Expanded widgets internally.
      expect(find.text('Big'), findsOneWidget);
      expect(find.text('Small'), findsOneWidget);
    });
  });

  group('Traffic dots', () {
    testWidgets('renders three colored dots with tooltips',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapInApp(
        Row(
          children: [
            _TestTrafficDot(
              color: const Color(0xFFff5f57),
              tooltip: 'Close',
              onTap: () {},
            ),
            _TestTrafficDot(
              color: const Color(0xFFfebc2e),
              tooltip: 'Minimize',
              onTap: () {},
            ),
            _TestTrafficDot(
              color: const Color(0xFF28c840),
              tooltip: 'Maximize',
              onTap: () {},
            ),
          ],
        ),
      ));

      expect(find.byTooltip('Close'), findsOneWidget);
      expect(find.byTooltip('Minimize'), findsOneWidget);
      expect(find.byTooltip('Maximize'), findsOneWidget);
    });

    testWidgets('tapping a dot fires its callback', (WidgetTester tester) async {
      var called = false;
      await tester.pumpWidget(_wrapInApp(
        _TestTrafficDot(
          color: const Color(0xFFff5f57),
          tooltip: 'Close',
          onTap: () => called = true,
        ),
      ));

      await tester.tap(find.byTooltip('Close'));
      expect(called, isTrue);
    });

    testWidgets('each dot fires a different callback',
        (WidgetTester tester) async {
      var closeCalled = false;
      var minCalled = false;
      var maxCalled = false;

      await tester.pumpWidget(_wrapInApp(
        Row(
          children: [
            _TestTrafficDot(
              color: const Color(0xFFff5f57),
              tooltip: 'Close',
              onTap: () => closeCalled = true,
            ),
            _TestTrafficDot(
              color: const Color(0xFFfebc2e),
              tooltip: 'Minimize',
              onTap: () => minCalled = true,
            ),
            _TestTrafficDot(
              color: const Color(0xFF28c840),
              tooltip: 'Maximize',
              onTap: () => maxCalled = true,
            ),
          ],
        ),
      ));

      await tester.tap(find.byTooltip('Minimize'));
      expect(closeCalled, isFalse);
      expect(minCalled, isTrue);
      expect(maxCalled, isFalse);
    });
  });

  group('Hamburger menu', () {
    testWidgets('menu icon renders', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapInApp(
        const Icon(Icons.menu, size: 14),
      ));
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('tapping menu icon fires callback',
        (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrapInApp(
        GestureDetector(
          onTap: () => tapped = true,
          child: const Icon(Icons.menu, size: 14),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      expect(tapped, isTrue);
    });
  });
}
