import 'package:flutter/foundation.dart';

import 'tree_node.dart';

/// Strategy pattern interface for feeding data into [ExplorerTreeView].
///
/// Implement this class to provide your own data source, lazy loading,
/// and action handlers. The widget calls these methods to render the tree.
///
/// A minimal implementation only needs [rootNodes] and [onNodeTap]:
/// ```dart
/// class MyExplorerController extends ExplorerController {
///   @override
///   List<TreeNode> get rootNodes => _myNodes;
///
///   @override
///   void onNodeTap(TreeNode node) {
///     print('Tapped: ${node.label}');
///   }
/// }
/// ```
abstract class ExplorerController extends ChangeNotifier {
  /// The top-level nodes to display in the tree.
  List<TreeNode> get rootNodes;

  /// Called when a node is tapped. Override to handle selection / navigation.
  void onNodeTap(TreeNode node) {}

  /// Called when a folder node is expanded. Override for lazy loading.
  void onNodeExpanded(TreeNode node) {}

  /// Called when a folder node is collapsed.
  void onNodeCollapsed(TreeNode node) {}

  /// Called when a context menu item is tapped on a node.
  void onContextMenuAction(TreeNode node, ContextMenuItem item) {
    item.onTap?.call();
  }

  /// Called when a node drag starts. Return true to allow the drag.
  bool onDragStart(TreeNode node) => true;

  /// Called when a node is dropped onto a target folder.
  void onDragDrop(TreeNode draggedNode, TreeNode targetFolder) {}

  /// Called when the user renames a node inline.
  void onNodeRenamed(TreeNode node, String newLabel) {}

  /// Called when a new node is requested (e.g. via context menu "New File").
  void onNewNode(TreeNode? parentFolder, {required bool isFile}) {}
}

/// A simple [ExplorerController] backed by an in-memory tree.
///
/// Useful for quick prototyping without implementing a full controller.
class SimpleExplorerController extends ExplorerController {
  final List<TreeNode> _rootNodes;

  /// Optional external callbacks — set these to handle events.
  final void Function(TreeNode node)? onTap;
  final void Function(TreeNode node)? onExpanded;
  final void Function(TreeNode node)? onCollapsed;
  final void Function(TreeNode node, ContextMenuItem item)? onContextAction;

  SimpleExplorerController({
    required List<TreeNode> rootNodes,
    this.onTap,
    this.onExpanded,
    this.onCollapsed,
    this.onContextAction,
  }) : _rootNodes = rootNodes;

  @override
  List<TreeNode> get rootNodes => _rootNodes;

  @override
  void onNodeTap(TreeNode node) => onTap?.call(node);

  @override
  void onNodeExpanded(TreeNode node) => onExpanded?.call(node);

  @override
  void onNodeCollapsed(TreeNode node) => onCollapsed?.call(node);

  @override
  void onContextMenuAction(TreeNode node, ContextMenuItem item) =>
      onContextAction?.call(node, item);
}
