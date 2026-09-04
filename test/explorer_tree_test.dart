import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterlane/flutterlane.dart';

void main() {
  group('TreeNode', () {
    test('creates with required fields', () {
      final node = TreeNode(id: '1', label: 'test');
      expect(node.id, '1');
      expect(node.label, 'test');
      expect(node.isFolder, false);
      expect(node.children, isEmpty);
      expect(node.badgeCount, isNull);
    });

    test('findById finds nested node', () {
      final child = TreeNode(id: 'child', label: 'Child');
      final parent = TreeNode(
        id: 'parent',
        label: 'Parent',
        isFolder: true,
        children: [child],
      );

      expect(parent.findById('child'), child);
      expect(parent.findById('nonexistent'), isNull);
      expect(parent.findById('parent'), parent);
    });

    test('collectIds returns all ids depth-first', () {
      final grandchild = TreeNode(id: 'gc', label: 'GC');
      final child = TreeNode(
        id: 'c',
        label: 'C',
        children: [grandchild],
      );
      final root = TreeNode(id: 'r', label: 'R', children: [child]);

      expect(root.collectIds(), ['r', 'c', 'gc']);
    });

    test('copyWith overrides specified fields', () {
      final original = TreeNode(id: '1', label: 'A', badgeCount: 5);
      final copied = original.copyWith(label: 'B', clearBadgeCount: true);

      expect(copied.id, '1');
      expect(copied.label, 'B');
      expect(copied.badgeCount, isNull);
    });

    test('equality by id, label, and isFolder', () {
      final a = TreeNode(id: '1', label: 'A');
      final b = TreeNode(id: '1', label: 'A');
      final c = TreeNode(id: '2', label: 'A');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('ContextMenuItem', () {
    test('creates regular item', () {
      final item = ContextMenuItem(label: 'Copy', icon: Icons.copy);
      expect(item.label, 'Copy');
      expect(item.isDivider, false);
    });

    test('creates divider', () {
      final item = ContextMenuItem.divider();
      expect(item.isDivider, true);
      expect(item.label, '');
    });
  });

  group('SimpleExplorerController', () {
    test('returns root nodes', () {
      final nodes = [
        TreeNode(id: '1', label: 'File 1'),
        TreeNode(id: '2', label: 'File 2'),
      ];
      final controller = SimpleExplorerController(rootNodes: nodes);

      expect(controller.rootNodes, nodes);
    });

    test('onTap callback fires', () {
      TreeNode? tapped;
      final controller = SimpleExplorerController(
        rootNodes: [],
        onTap: (node) => tapped = node,
      );

      final node = TreeNode(id: '1', label: 'Test');
      controller.onNodeTap(node);
      expect(tapped, node);
    });

    test('onExpanded callback fires', () {
      TreeNode? expanded;
      final controller = SimpleExplorerController(
        rootNodes: [],
        onExpanded: (node) => expanded = node,
      );

      final node = TreeNode(id: '1', label: 'Folder', isFolder: true);
      controller.onNodeExpanded(node);
      expect(expanded, node);
    });
  });
}
