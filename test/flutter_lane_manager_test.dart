import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterlane/flutterlane.dart';

Widget _noopBuilder(
  BuildContext context,
  String bizCtx,
  Map<String, dynamic> state,
) =>
    const SizedBox();

void main() {
  // Helper: creates a LayoutState with a swimlane containing a section.
  LayoutState _makeLayout({
    String swId = 'sw-1',
    String secId = 'sec-1',
    String? secTitle,
    List<Pane>? panes,
    bool isSystemDefault = false,
  }) {
    final section = Section(
      sectionId: secId,
      title: secTitle ?? 'Section 1',
      panes: panes ?? [],
    );
    final swimlane = Swimlane(id: swId, sections: [section]);
    return LayoutState(
      layoutName: 'Test',
      isSystemDefault: isSystemDefault,
      isCurrentActive: true,
      swimlanes: [swimlane],
    );
  }

  group('FlutterLaneManager CRUD operations', () {
    late FlutterLaneManager manager;

    setUp(() {
      manager = FlutterLaneManager();
      manager.loadLayout(_makeLayout());
    });

    test('addSwimlane adds to active layout', () {
      manager.addSwimlane(Swimlane(
        id: 'sw-2',
        sections: [Section(title: 'Second')],
      ));
      expect(manager.activeLayout!.swimlanes.length, 2);
    });

    test('removeSwimlane removes from active layout', () {
      manager.addSwimlane(Swimlane(
        id: 'removable',
        sections: [Section(title: 'Temp')],
      ));
      final removed = manager.removeSwimlane('removable');
      expect(removed, isNotNull);
      expect(manager.activeLayout!.swimlanes.length, 1);
    });

    test('addSectionToSwimlane adds section', () {
      manager.addSectionToSwimlane(
        'sw-1',
        Section(sectionId: 'sec-new', title: 'New'),
      );
      final sw = manager.activeLayout!.swimlanes.first;
      expect(sw.sections.length, 2);
    });

    test('removeSectionFromSwimlane removes section', () {
      manager.removeSectionFromSwimlane('sw-1', 'sec-1');
      final sw = manager.activeLayout!.swimlanes.first;
      expect(sw.sections.length, 1);
      expect(sw.sections.first.isPlaceholder, isTrue);
    });

    test('addPaneToSection adds pane', () {
      manager.addPaneToSection(
        'sw-1',
        'sec-1',
        Pane(
          paneId: 'p1',
          viewInstance: const ViewInstance(viewTypeId: 'explorer'),
        ),
      );
      final section = manager.activeLayout!.swimlanes.first.sections.first;
      expect(section.panes.length, 1);
    });

    test('activatePane switches active tab', () {
      manager.addPaneToSection(
        'sw-1',
        'sec-1',
        Pane(
          paneId: 'p-a',
          viewInstance: const ViewInstance(viewTypeId: 'v1'),
        ),
      );
      manager.addPaneToSection(
        'sw-1',
        'sec-1',
        Pane(
          paneId: 'p-b',
          viewInstance: const ViewInstance(viewTypeId: 'v2'),
        ),
      );
      manager.activatePane('sw-1', 'sec-1', 'p-b');
      final section = manager.activeLayout!.swimlanes.first.sections.first;
      expect(section.activePaneId, 'p-b');
    });

    test('toggleSectionExpanded toggles state', () {
      manager.toggleSectionExpanded('sw-1', 'sec-1');
      final section = manager.activeLayout!.swimlanes.first.sections.first;
      expect(section.isExpanded, false);
      manager.toggleSectionExpanded('sw-1', 'sec-1');
      expect(section.isExpanded, true);
    });

    test('updateSwimlaneFlex changes flex', () {
      manager.updateSwimlaneFlex('sw-1', 3.0);
      final sw = manager.activeLayout!.swimlanes.first;
      expect(sw.flex, 3.0);
    });
  });

  group('FlutterLaneManager cross-layer moves', () {
    late FlutterLaneManager manager;

    setUp(() {
      manager = FlutterLaneManager();
      manager.loadLayout(_makeLayout());
    });

    test('movePane within same swimlane reorders', () {
      manager.addPaneToSection(
        'sw-1',
        'sec-1',
        Pane(
          paneId: 'p1',
          viewInstance: const ViewInstance(viewTypeId: 'v1'),
        ),
      );
      manager.addPaneToSection(
        'sw-1',
        'sec-1',
        Pane(
          paneId: 'p2',
          viewInstance: const ViewInstance(viewTypeId: 'v2'),
        ),
      );

      manager.movePane(
        fromSwimlaneId: 'sw-1',
        fromSectionId: 'sec-1',
        toSwimlaneId: 'sw-1',
        toSectionId: 'sec-1',
        paneId: 'p2',
        toIndex: 0,
      );

      final section = manager.activeLayout!.swimlanes.first.sections.first;
      expect(section.panes.first.paneId, 'p2');
    });

    test('movePane across swimlanes', () {
      manager.addSwimlane(Swimlane(
        id: 'sw-b',
        sections: [Section(sectionId: 'sec-b', title: 'B')],
      ));
      manager.addPaneToSection(
        'sw-1',
        'sec-1',
        Pane(
          paneId: 'p-cross',
          viewInstance: const ViewInstance(viewTypeId: 'v1'),
        ),
      );

      manager.movePane(
        fromSwimlaneId: 'sw-1',
        fromSectionId: 'sec-1',
        toSwimlaneId: 'sw-b',
        toSectionId: 'sec-b',
        paneId: 'p-cross',
      );

      final sourceSection =
          manager.activeLayout!.swimlanes[0].sections[0];
      final targetSection =
          manager.activeLayout!.swimlanes[1].sections[0];

      expect(sourceSection.panes, isEmpty);
      expect(targetSection.panes.length, 1);
      expect(targetSection.panes.first.paneId, 'p-cross');
    });

    test('moveSection across swimlanes', () {
      manager.addSwimlane(Swimlane(
        id: 'sw-y',
        sections: [Section(sectionId: 'sec-y', title: 'Y')],
      ));
      manager.addSectionToSwimlane(
        'sw-1',
        Section(sectionId: 'sec-move', title: 'Move Me'),
      );

      manager.moveSection(
        fromSwimlaneId: 'sw-1',
        toSwimlaneId: 'sw-y',
        sectionId: 'sec-move',
      );

      final source = manager.activeLayout!.swimlanes[0];
      final target = manager.activeLayout!.swimlanes[1];

      expect(source.sections.every((s) => s.sectionId != 'sec-move'), isTrue);
      expect(target.sections.any((s) => s.sectionId == 'sec-move'), isTrue);
    });
  });

  group('FlutterLaneManager resize', () {
    late FlutterLaneManager manager;

    setUp(() {
      manager = FlutterLaneManager();
      manager.loadLayout(_makeLayout());
    });

    test('resizeSection adjusts flex of adjacent sections', () {
      manager.addSectionToSwimlane(
        'sw-1',
        Section(sectionId: 'sec-top', title: 'Top', flex: 1.0),
      );
      manager.addSectionToSwimlane(
        'sw-1',
        Section(sectionId: 'sec-bot', title: 'Bottom', flex: 1.0),
      );

      manager.resizeSection('sw-1', 'sec-top', 0.5);

      final swimlane = manager.activeLayout!.swimlanes.first;
      final top = swimlane.sections
          .firstWhere((s) => s.sectionId == 'sec-top');
      final bot = swimlane.sections
          .firstWhere((s) => s.sectionId == 'sec-bot');

      expect(top.flex, greaterThan(1.0));
      expect(bot.flex, lessThan(1.0));
    });

    test('resizeSection is safe with invalid section', () {
      manager.resizeSection('sw-1', 'nonexistent', 1.0);
    });
  });

  group('FlutterLaneManager layout snapshots', () {
    late FlutterLaneManager manager;

    setUp(() {
      manager = FlutterLaneManager();
      manager.loadLayout(_makeLayout());
    });

    test('saveAsNewLayout creates a new snapshot', () async {
      await manager.saveAsNewLayout('My Layout');
      expect(manager.layouts.length, 2);
      expect(manager.layouts[1].layoutName, 'My Layout');
    });

    test('deleteLayout protects active layout', () async {
      final activeId = manager.activeLayout!.snapshotId;
      final deleted = await manager.deleteLayout(activeId);
      expect(deleted, isFalse);
    });

    test('deleteLayout protects system default', () async {
      // Load a system-default layout (it gets added to the layouts list).
      final systemDefault = LayoutState.systemDefault();
      manager.loadLayout(systemDefault);

      final deleted = await manager.deleteLayout(systemDefault.snapshotId);
      expect(deleted, isFalse);
    });

    test('deleteLayout works on non-active, non-default layout', () async {
      final other = LayoutState(
        layoutName: 'Other',
        swimlanes: [],
      );
      manager.loadLayout(other);

      final deleted = await manager.deleteLayout(other.snapshotId);
      expect(deleted, isTrue);
    });
  });

  group('ThemeManager', () {
    late ThemeManager themeManager;

    setUp(() {
      themeManager = ThemeManager();
    });

    test('defaults to light theme', () {
      expect(themeManager.currentType, FlutterLaneThemeType.light);
      expect(themeManager.currentTheme, FlutterLaneThemeData.light);
    });

    test('setTheme switches theme', () async {
      await themeManager.setTheme(FlutterLaneThemeType.dark);
      expect(themeManager.currentType, FlutterLaneThemeType.dark);
      expect(themeManager.currentTheme, FlutterLaneThemeData.dark);
    });

    test('setTheme notifies listeners', () async {
      int notifyCount = 0;
      themeManager.addListener(() => notifyCount++);
      await themeManager.setTheme(FlutterLaneThemeType.pure);
      expect(notifyCount, 1);
    });

    test('setTheme does not notify if same', () async {
      int notifyCount = 0;
      themeManager.addListener(() => notifyCount++);
      await themeManager.setTheme(FlutterLaneThemeType.light);
      expect(notifyCount, 0);
    });

    test('adaptToSystem changes to dark on dark brightness', () async {
      themeManager.setFollowSystem(true);
      await themeManager.adaptToSystem(Brightness.dark);
      expect(themeManager.currentType, FlutterLaneThemeType.dark);
    });

    test('adaptToSystem ignores when followSystem is false', () async {
      await themeManager.setFollowSystem(false);
      await themeManager.adaptToSystem(Brightness.dark);
      expect(themeManager.currentType, FlutterLaneThemeType.light);
    });

    test('all three built-in themes are distinct', () {
      expect(FlutterLaneThemeData.light != FlutterLaneThemeData.dark, isTrue);
      expect(FlutterLaneThemeData.dark != FlutterLaneThemeData.pure, isTrue);
      expect(FlutterLaneThemeData.light != FlutterLaneThemeData.pure, isTrue);
    });

    test('FlutterLaneThemeData.lerp interpolates correctly', () {
      final mid = FlutterLaneThemeData.lerp(
        FlutterLaneThemeData.light,
        FlutterLaneThemeData.dark,
        0.5,
      );
      expect(mid, isNot(equals(FlutterLaneThemeData.light)));
      expect(mid, isNot(equals(FlutterLaneThemeData.dark)));
    });
  });

  group('FlutterLaneRegistry', () {
    late FlutterLaneRegistry registry;

    setUp(() {
      registry = FlutterLaneRegistry();
    });

    test('registerPaneView and retrieve', () {
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'explorer',
        viewDisplayName: 'Explorer',
        icon: Icons.folder,
        viewBuilder: _noopBuilder,
      ));
      final meta = registry.getPaneView('explorer');
      expect(meta, isNotNull);
      expect(meta!.viewDisplayName, 'Explorer');
    });

    test('unregisterPaneView removes', () {
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'test',
        viewDisplayName: 'Test',
        icon: Icons.check,
        viewBuilder: _noopBuilder,
      ));
      registry.unregisterPaneView('test');
      expect(registry.getPaneView('test'), isNull);
    });

    test('allPaneViews returns registered views', () {
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'a',
        viewDisplayName: 'A',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'b',
        viewDisplayName: 'B',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));
      expect(registry.allPaneViews.length, 2);
    });

    test('getPaneViewsForContext filters by context', () {
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'a',
        viewDisplayName: 'A',
        icon: Icons.star,
        supportBusinessContexts: ['python'],
        viewBuilder: _noopBuilder,
      ));
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'b',
        viewDisplayName: 'B',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));
      final pythonViews = registry.getPaneViewsForContext('python');
      expect(pythonViews.length, 2);
    });

    test('clearAll removes everything', () {
      registry.registerPaneView(ViewInstanceMeta(
        viewTypeId: 'x',
        viewDisplayName: 'X',
        icon: Icons.star,
        viewBuilder: _noopBuilder,
      ));
      registry.clearAll();
      expect(registry.allPaneViews, isEmpty);
    });
  });
}
