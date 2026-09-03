import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutterlane/flutterlane.dart';
import 'package:flutterlane_example/main.dart' as example;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FlutterLaneManager manager;
  late FlutterLaneRegistry registry;

  Pane pane(String id, String type) => Pane(
        paneId: id,
        viewInstance: ViewInstance(viewTypeId: type),
      );

  LayoutState layout() => LayoutState(
        layoutName: 'Acceptance',
        isSystemDefault: false,
        isCurrentActive: true,
        swimlanes: [
          Swimlane(
            id: 'lane-a',
            canClose: false,
            sections: [
              Section(
                sectionId: 'section-a',
                title: 'Explorer',
                panes: [pane('pane-a1', 'editor'), pane('pane-a2', 'search')],
                activePaneId: 'pane-a1',
              ),
            ],
          ),
          Swimlane(
            id: 'lane-b',
            sections: [
              Section(
                sectionId: 'section-b',
                title: 'Operations',
                panes: [pane('pane-b1', 'terminal')],
                activePaneId: 'pane-b1',
              ),
            ],
          ),
        ],
      );

  Widget app() => MaterialApp(
        home: FlutterLaneTheme(
          data: FlutterLaneThemeData.dark,
          child: Scaffold(body: FlutterLaneWorkbench(manager: manager)),
        ),
      );

  setUp(() {
    manager = FlutterLaneManager();
    registry = manager.registry;
    for (final type in ['editor', 'search', 'terminal', 'output']) {
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: type,
        viewDisplayName: type,
        icon: Icons.widgets_outlined,
        viewBuilder: (context, businessContext, state) => Text(type),
      ));
    }
    manager.loadLayout(layout());
  });

  testWidgets('opens workbench and exercises section tab actions',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byType(FlutterLaneWorkbench), findsOneWidget);
    expect(find.text('Explorer'), findsOneWidget);
    expect(find.text('editor'), findsWidgets);

    await tester.tap(find.text('search'));
    await tester.pumpAndSettle();
    expect(manager.activeLayout!.swimlanes.first.sections.first.activePaneId,
        'pane-a2');

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();
    expect(manager.activeLayout!.swimlanes.first.sections.first.isExpanded,
        isFalse);

    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pumpAndSettle();
    expect(manager.activeLayout!.swimlanes.first.sections.first.isExpanded,
        isTrue);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect(manager.activeLayout!.swimlanes.first.sections.first.panes,
        hasLength(1));
  });

  testWidgets('adds a registered pane through the section plus menu',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('output').last);
    await tester.pumpAndSettle();

    expect(
        manager.activeLayout!.swimlanes.first.sections.first.panes.last
            .viewInstance.viewTypeId,
        'output');
  });

  testWidgets('drags a pane across sections and a section across swimlanes',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final sourcePane = tester.getCenter(find.text('search'));
    final targetSection = tester.getCenter(find.text('Operations'));
    final paneGesture = await tester.startGesture(sourcePane);
    await paneGesture.moveTo(targetSection);
    await paneGesture.up();
    await tester.pumpAndSettle();

    expect(manager.activeLayout!.swimlanes[0].sections[0].panes, hasLength(1));
    expect(
        manager.activeLayout!.swimlanes[1].sections[0].panes
            .any((p) => p.paneId == 'pane-a2'),
        isTrue);

    final sourceSection = tester.getCenter(
      find.byKey(const ValueKey('section-drag-section-a')),
    );
    final targetLane = tester.getCenter(
      find.byKey(const ValueKey('section-drop-section-b')),
    );
    await tester.drag(
      find.byKey(const ValueKey('section-drag-section-a')),
      targetLane - sourceSection,
    );
    await tester.pumpAndSettle();

    expect(manager.activeLayout!.swimlanes[0].sections, isEmpty);
    expect(manager.activeLayout!.swimlanes[1].sections.map((s) => s.sectionId),
        contains('section-a'));
  });

  testWidgets('resizes sections through the visible resize handle',
      (tester) async {
    final active = manager.activeLayout!;
    active.swimlanes.first.sections
        .add(Section(sectionId: 'section-a2', title: 'Problems'));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final before = active.swimlanes.first.sections.first.flex;
    final handle = find.byKey(const ValueKey('section-resize-section-a'));
    expect(handle, findsOneWidget);
    await tester.drag(handle, const Offset(0, 30));
    await tester.pumpAndSettle();

    expect(active.swimlanes.first.sections.first.flex, isNot(before));
  });

  testWidgets('adds a swimlane without overflow and resizes the splitter',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final hotZone = find.byType(AddSwimlaneHotZone);
    await tester.tapAt(tester.getCenter(hotZone));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(manager.activeLayout!.swimlanes, hasLength(3));

    final before = manager.activeLayout!.swimlanes.first.flex;
    await tester.drag(
      find.byKey(const ValueKey('swimlane-resize-lane-a')),
      const Offset(40, 0),
    );
    await tester.pumpAndSettle();

    expect(manager.activeLayout!.swimlanes.first.flex, isNot(before));
  });

  testWidgets('shows a configurable swimlane close button', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('swimlane-close')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('swimlane-close')));
    await tester.pumpAndSettle();

    expect(manager.activeLayout!.swimlanes, hasLength(1));
    expect(manager.activeLayout!.swimlanes.first.id, 'lane-a');
    expect(find.byKey(const ValueKey('swimlane-close')), findsNothing);
  });

  testWidgets('persists the last layout across manager restart',
      (tester) async {
    await manager.init();
    final original = manager.activeLayout!.clone();
    final active = manager.activeLayout!;
    active.layoutName = 'Restart Persistence';
    active.swimlanes.first.sections.first.title = 'Editor / main.dart';
    active.swimlanes.first.sections.first.isExpanded = false;
    active.swimlanes.first.flex = 1.75;
    await manager.save();

    final reopened = FlutterLaneManager();
    await reopened.init();
    final restored = reopened.activeLayout!;

    expect(restored.layoutName, 'Restart Persistence');
    expect(restored.swimlanes.first.sections.first.title, 'Editor / main.dart');
    expect(restored.swimlanes.first.sections.first.isExpanded, isFalse);
    expect(restored.swimlanes.first.flex, 1.75);

    active.layoutName = original.layoutName;
    active.swimlanes = original.swimlanes;
    await manager.save();
  });

  testWidgets('resets the active layout to a pristine default', (tester) async {
    await tester.pumpWidget(const example.FlutterLaneExampleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('reset-default-layout')));
    await tester.pumpAndSettle();

    expect(find.text('Layout: Default'), findsOneWidget);
  });
}
