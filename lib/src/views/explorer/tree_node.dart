import 'package:flutter/material.dart';

class ContextMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isDivider;

  const ContextMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.isDivider = false,
  });

  const ContextMenuItem.divider()
      : label = '',
        icon = null,
        onTap = null,
        isDivider = true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextMenuItem &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          isDivider == other.isDivider;

  @override
  int get hashCode => label.hashCode ^ isDivider.hashCode;
}

class TreeNode {
  final String id;
  final String label;
  final IconData? icon;
  final bool isFolder;
  final List<TreeNode> children;
  final int? badgeCount;
  final List<ContextMenuItem> contextMenuItems;
  final bool isDraggable;
  final bool initiallyExpanded;

  const TreeNode({
    required this.id,
    required this.label,
    this.icon,
    this.isFolder = false,
    this.children = const [],
    this.badgeCount,
    this.contextMenuItems = const [],
    this.isDraggable = false,
    this.initiallyExpanded = false,
  });

  TreeNode copyWith({
    String? id,
    String? label,
    IconData? icon,
    bool? isFolder,
    List<TreeNode>? children,
    int? badgeCount,
    bool clearBadgeCount = false,
    List<ContextMenuItem>? contextMenuItems,
    bool? isDraggable,
    bool? initiallyExpanded,
  }) {
    return TreeNode(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isFolder: isFolder ?? this.isFolder,
      children: children ?? this.children,
      badgeCount: clearBadgeCount ? null : (badgeCount ?? this.badgeCount),
      contextMenuItems: contextMenuItems ?? this.contextMenuItems,
      isDraggable: isDraggable ?? this.isDraggable,
      initiallyExpanded: initiallyExpanded ?? this.initiallyExpanded,
    );
  }

  /// Recursively find a node by id in the tree.
  TreeNode? findById(String targetId) {
    if (id == targetId) return this;
    for (final child in children) {
      final found = child.findById(targetId);
      if (found != null) return found;
    }
    return null;
  }

  /// Collect all node ids in depth-first order.
  List<String> collectIds() {
    final ids = <String>[id];
    for (final child in children) {
      ids.addAll(child.collectIds());
    }
    return ids;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          isFolder == other.isFolder;

  @override
  int get hashCode => id.hashCode ^ label.hashCode ^ isFolder.hashCode;
}
