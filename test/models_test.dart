import 'package:flutter_test/flutter_test.dart';
import 'package:flutterlane/flutterlane.dart';

void main() {
  group('ViewInstance', () {
    test('equality by viewTypeId and businessContext', () {
      const a = ViewInstance(
        viewTypeId: 'explorer',
        businessContext: '/project',
      );
      const b = ViewInstance(
        viewTypeId: 'explorer',
        businessContext: '/project',
      );
      const c = ViewInstance(
        viewTypeId: 'terminal',
        businessContext: '/project',
      );
      expect(a, equals(b));
      expect(a == c, isFalse);
    });

    test('copyWith overrides fields', () {
      const original = ViewInstance(
        viewTypeId: 'explorer',
        businessContext: '/a',
        viewState: {'collapsed': true},
      );
      final copy = original.copyWith(viewTypeId: 'terminal');
      expect(copy.viewTypeId, 'terminal');
      expect(copy.businessContext, '/a');
      expect(copy.viewState, {'collapsed': true});
    });

    test('toJson/fromJson roundtrip', () {
      const original = ViewInstance(
        viewTypeId: 'search',
        businessContext: '/ws',
        viewState: {'query': 'foo'},
      );
      final json = original.toJson();
      final restored = ViewInstance.fromJson(json);
      expect(restored.viewTypeId, original.viewTypeId);
      expect(restored.businessContext, original.businessContext);
      expect(restored.viewState, original.viewState);
    });
  });

  group('Pane', () {
    test('creates with generated ID', () {
      final pane = Pane(
        paneId: generateId(),
        viewInstance: const ViewInstance(viewTypeId: 'test'),
      );
      expect(pane.paneId.isNotEmpty, isTrue);
    });

    test('toJson/fromJson roundtrip', () {
      final original = Pane(
        paneId: 'pane-123',
        viewInstance: const ViewInstance(
          viewTypeId: 'terminal',
          businessContext: '/proj',
        ),
      );
      final json = original.toJson();
      final restored = Pane.fromJson(json);
      expect(restored.paneId, 'pane-123');
      expect(restored.viewInstance.viewTypeId, 'terminal');
    });
  });

  group('Section', () {
    test('placeholder is empty', () {
      final placeholder = Section.placeholder();
      expect(placeholder.isPlaceholder, isTrue);
      expect(placeholder.panes, isEmpty);
    });

    test('addPane auto-activates first', () {
      final section = Section(title: 'Test');
      final pane = Pane(
        paneId: 'p1',
        viewInstance: const ViewInstance(viewTypeId: 'v1'),
      );
      section.addPane(pane);
      expect(section.activePaneId, 'p1');
      expect(section.activePane, pane);
    });

    test('addPane does not override active if already set', () {
      final section = Section(title: 'Test');
      final p1 = Pane(
        paneId: 'p1',
        viewInstance: const ViewInstance(viewTypeId: 'v1'),
      );
      final p2 = Pane(
        paneId: 'p2',
        viewInstance: const ViewInstance(viewTypeId: 'v2'),
      );
      section.addPane(p1);
      section.addPane(p2);
      expect(section.activePaneId, 'p1');
    });

    test('activatePane switches active', () {
      final section = Section(title: 'Test', panes: [
        Pane(paneId: 'p1', viewInstance: const ViewInstance(viewTypeId: 'v1')),
        Pane(paneId: 'p2', viewInstance: const ViewInstance(viewTypeId: 'v2')),
      ]);
      section.activatePane('p2');
      expect(section.activePaneId, 'p2');
    });

    test('removePane auto-selects adjacent', () {
      final section = Section(title: 'Test', panes: [
        Pane(paneId: 'p1', viewInstance: const ViewInstance(viewTypeId: 'v1')),
        Pane(paneId: 'p2', viewInstance: const ViewInstance(viewTypeId: 'v2')),
        Pane(paneId: 'p3', viewInstance: const ViewInstance(viewTypeId: 'v3')),
      ]);
      section.activatePane('p2');
      final removed = section.removePane('p2');
      expect(removed, isNotNull);
      expect(section.panes.length, 2);
      expect(section.activePaneId, isNotNull);
    });

    test('removePane on last pane leaves activePaneId null', () {
      final section = Section(panes: [
        Pane(paneId: 'p1', viewInstance: const ViewInstance(viewTypeId: 'v1')),
      ]);
      section.removePane('p1');
      expect(section.panes, isEmpty);
      expect(section.activePaneId, isNull);
    });

    test('toJson/fromJson roundtrip', () {
      final original = Section(
        sectionId: 'sec-1',
        title: 'Explorer',
        isExpanded: false,
        flex: 2.0,
        panes: [
          Pane(
            paneId: 'p1',
            viewInstance: const ViewInstance(viewTypeId: 'v1'),
          ),
        ],
        activePaneId: 'p1',
      );
      final json = original.toJson();
      final restored = Section.fromJson(json);
      expect(restored.sectionId, 'sec-1');
      expect(restored.title, 'Explorer');
      expect(restored.isExpanded, false);
      expect(restored.flex, 2.0);
      expect(restored.panes.length, 1);
      expect(restored.activePaneId, 'p1');
    });
  });

  group('Swimlane', () {
    test('ensurePlaceholder adds one when empty', () {
      final swimlane = Swimlane(sections: []);
      swimlane.ensurePlaceholder();
      expect(swimlane.sections.length, 1);
      expect(swimlane.sections.first.isPlaceholder, isTrue);
    });

    test('ensurePlaceholder does nothing when not empty', () {
      final swimlane = Swimlane(sections: [
        Section(title: 'A'),
      ]);
      swimlane.ensurePlaceholder();
      expect(swimlane.sections.length, 1);
    });

    test('removeSection auto-injects placeholder', () {
      final swimlane = Swimlane(sections: [
        Section(sectionId: 's1', title: 'Only'),
      ]);
      swimlane.removeSection('s1');
      expect(swimlane.sections.length, 1);
      expect(swimlane.sections.first.isPlaceholder, isTrue);
    });

    test('addSection at index', () {
      final swimlane = Swimlane(sections: [
        Section(sectionId: 's1'),
      ]);
      swimlane.addSection(Section(sectionId: 's2'), index: 0);
      expect(swimlane.sections.first.sectionId, 's2');
    });

    test('toJson/fromJson roundtrip', () {
      final original = Swimlane(
        id: 'sw-1',
        flex: 2.0,
        minWidth: 200.0,
        sections: [
          Section(sectionId: 's1', title: 'A'),
          Section(sectionId: 's2', title: 'B'),
        ],
      );
      final json = original.toJson();
      final restored = Swimlane.fromJson(json);
      expect(restored.id, 'sw-1');
      expect(restored.flex, 2.0);
      expect(restored.minWidth, 200.0);
      expect(restored.sections.length, 2);
      expect(restored.sections[0].title, 'A');
    });
  });

  group('LayoutState', () {
    test('systemDefault creates one swimlane with placeholder', () {
      final layout = LayoutState.systemDefault();
      expect(layout.isSystemDefault, isTrue);
      expect(layout.isCurrentActive, isTrue);
      expect(layout.layoutName, 'Default');
      expect(layout.swimlanes.length, 1);
      expect(layout.swimlanes.first.sections.length, 1);
      expect(layout.swimlanes.first.sections.first.isPlaceholder, isTrue);
    });

    test('clone produces independent deep copy', () {
      final original = LayoutState(
        layoutName: 'Test',
        swimlanes: [
          Swimlane(sections: [Section(title: 'X')]),
        ],
      );
      final cloned = original.clone();
      cloned.swimlanes.first.sections.first.title = 'Y';
      expect(original.swimlanes.first.sections.first.title, 'X');
    });

    test('addSwimlane and removeSwimlane', () {
      final layout = LayoutState(swimlanes: []);
      final sw = Swimlane(id: 'sw-1');
      layout.addSwimlane(sw);
      expect(layout.swimlanes.length, 1);

      layout.removeSwimlane('sw-1');
      expect(layout.swimlanes, isEmpty);
    });

    test('toJson/fromJson roundtrip', () {
      final original = LayoutState(
        layoutName: 'Custom',
        swimlanes: [
          Swimlane(
            id: 'sw-1',
            sections: [
              Section(
                sectionId: 's1',
                title: 'Explorer',
                panes: [
                  Pane(
                    paneId: 'p1',
                    viewInstance: const ViewInstance(viewTypeId: 'v1'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final json = original.toJson();
      final restored = LayoutState.fromJson(json);
      expect(restored.layoutName, 'Custom');
      expect(restored.swimlanes.length, 1);
      expect(restored.swimlanes.first.sections.first.title, 'Explorer');
      expect(
          restored.swimlanes.first.sections.first.panes.first.paneId, 'p1');
    });
  });

  group('Workspace', () {
    test('defaults creates workspace with default layout', () {
      final ws = Workspace.defaults(workspaceName: 'Test');
      expect(ws.workspaceName, 'Test');
      expect(ws.layouts.length, 1);
      expect(ws.activeLayout, isNotNull);
      expect(ws.activeLayoutId, isNotNull);
    });

    test('toJson/fromJson roundtrip', () {
      final original = Workspace(
        workspaceId: 'ws-1',
        workspaceName: 'My Workspace',
        themeType: FlutterLaneThemeType.dark,
      );
      final json = original.toJson();
      final restored = Workspace.fromJson(json);
      expect(restored.workspaceId, 'ws-1');
      expect(restored.workspaceName, 'My Workspace');
      expect(restored.themeType, FlutterLaneThemeType.dark);
    });

    test('activeLayout returns null when no layouts', () {
      final ws = Workspace(workspaceId: 'empty');
      expect(ws.activeLayout, isNull);
    });
  });

  group('generateId', () {
    test('generates unique IDs', () {
      final ids = List.generate(100, (_) => generateId());
      expect(ids.toSet().length, 100);
    });

    test('generates UUID v4 format', () {
      final id = generateId();
      expect(id.length, 36);
      expect(id[8], '-');
      expect(id[13], '-');
      expect(id[18], '-');
      expect(id[23], '-');
    });
  });
}
