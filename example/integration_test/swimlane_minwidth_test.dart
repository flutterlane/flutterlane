import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutterlane/flutterlane.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FlutterLaneManager manager;

  Widget app() => MaterialApp(
        home: FlutterLaneTheme(
          data: FlutterLaneThemeData.dark,
          child: Scaffold(body: FlutterLaneWorkbench(manager: manager)),
        ),
      );

  setUp(() {
    final workspace = Workspace(
      workspaceId: 'minwidth-test',
      workspaceName: 'MinWidth Test',
    );
    manager = FlutterLaneManager(workspace: workspace);
    manager.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'editor',
      viewDisplayName: 'Editor',
      icon: Icons.code,
      viewBuilder: (context, bizCtx, state) => const Text('editor'),
    ));
  });

  testWidgets('new swimlane has minWidth of at least 120px', (tester) async {
    // Start with one swimlane
    manager.loadLayout(LayoutState(
      swimlanes: [
        Swimlane(
          id: 'lane-1',
          flex: 3,
          sections: [Section(title: 'A')],
        ),
      ],
    ));

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    // Add 5 more swimlanes via the hot zone
    final hotZone = find.byType(AddSwimlaneHotZone);
    for (var i = 0; i < 5; i++) {
      await tester.tapAt(tester.getCenter(hotZone));
      await tester.pumpAndSettle();
    }

    expect(manager.activeLayout!.swimlanes.length, 6);

    // Check rendered size of each swimlane
    for (final lane in manager.activeLayout!.swimlanes) {
      final finder = find.byKey(ValueKey('swimlane-close'));
      // Use the swimlane's content to find its RenderBox
      final swimlaneFinder = find.byType(SwimlaneWidget);
      final swimlanesFound = tester.widgetList<SwimlaneWidget>(swimlaneFinder);
      expect(swimlanesFound.length, 6);
    }

    // Verify all swimlanes have minWidth >= 120
    for (final lane in manager.activeLayout!.swimlanes) {
      expect(lane.minWidth, greaterThanOrEqualTo(120.0),
          reason: 'Swimlane ${lane.id} minWidth should be >= 120');
    }

    // Check actual rendered widths
    final swimlaneWidgets = find.byType(SwimlaneWidget);
    for (var i = 0; i < 6; i++) {
      final box = tester.renderObject<RenderBox>(swimlaneWidgets.at(i));
      final width = box.size.width;
      debugPrint('Swimlane $i rendered width: $width');
      // Each swimlane should be at least 100px (allowing some flex compression)
      expect(width, greaterThanOrEqualTo(100.0),
          reason: 'Swimlane $i rendered width $width should be >= 100');
    }
  });

  testWidgets('swimlane minWidth is enforced even with many siblings',
      (tester) async {
    // Create a layout with many swimlanes
    final swimlanes = <Swimlane>[];
    for (var i = 0; i < 8; i++) {
      swimlanes.add(Swimlane(
        id: 'lane-$i',
        flex: 1,
        sections: [Section(title: 'Section $i')],
      ));
    }

    manager.loadLayout(LayoutState(swimlanes: swimlanes));

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    // Check all swimlanes have minWidth 120
    for (final lane in manager.activeLayout!.swimlanes) {
      expect(lane.minWidth, 120.0);
    }

    // Verify no overflow errors
    expect(tester.takeException(), isNull);

    // Check rendered widths
    final swimlaneWidgets = find.byType(SwimlaneWidget);
    final count = tester.widgetList<SwimlaneWidget>(swimlaneWidgets).length;
    expect(count, 8);

    for (var i = 0; i < count; i++) {
      final box = tester.renderObject<RenderBox>(swimlaneWidgets.at(i));
      final width = box.size.width;
      debugPrint('Swimlane $i rendered width: $width');
      // With 8 swimlanes and 800px default test width, each gets ~100px
      // minWidth: 120 should be enforced
      expect(width, greaterThanOrEqualTo(120.0),
          reason: 'Swimlane $i should be at least 120px but was $width');
    }
  });
}
