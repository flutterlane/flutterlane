import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/flutter_lane_theme.dart';
import 'explorer_controller.dart';
import 'tree_node.dart';

/// A VS Code–style explorer tree view widget.
///
/// Feed it an [ExplorerController] that provides your tree data.
/// Supports: expand/collapse, context menus, badge counts, inline rename,
/// drag-and-drop (via controller callbacks), and themed styling.
class ExplorerTreeView extends StatefulWidget {
  final ExplorerController controller;

  /// Height of each row. Defaults to 28.
  final double rowHeight;

  /// Indent per nesting level. Defaults to 16.
  final double indentSize;

  /// Optional header widget shown above the tree (e.g. a search bar).
  final Widget? header;

  /// Optional "New File" / "New Folder" buttons shown in a toolbar.
  final bool showToolbar;

  const ExplorerTreeView({
    super.key,
    required this.controller,
    this.rowHeight = 28,
    this.indentSize = 16,
    this.header,
    this.showToolbar = false,
  });

  @override
  State<ExplorerTreeView> createState() => _ExplorerTreeViewState();
}

class _ExplorerTreeViewState extends State<ExplorerTreeView> {
  final Map<String, bool> _expanded = {};
  final Map<String, String?> _editingId = {};
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    _initExpandedState();
  }

  @override
  void didUpdateWidget(covariant ExplorerTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerUpdate);
      widget.controller.addListener(_onControllerUpdate);
      _initExpandedState();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _editController.dispose();
    super.dispose();
  }

  void _initExpandedState() {
    for (final node in widget.controller.rootNodes) {
      _initExpandedRecursive(node);
    }
  }

  void _initExpandedRecursive(TreeNode node) {
    if (_expanded.containsKey(node.id)) return;
    _expanded[node.id] = node.initiallyExpanded;
    for (final child in node.children) {
      _initExpandedRecursive(child);
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _toggleExpand(TreeNode node) {
    final isExpanded = _expanded[node.id] ?? false;
    setState(() => _expanded[node.id] = !isExpanded);
    if (!isExpanded) {
      widget.controller.onNodeExpanded(node);
    } else {
      widget.controller.onNodeCollapsed(node);
    }
  }

  /// Start inline rename on a node. Can be called externally (e.g. from context menu).
  void startRename(TreeNode node) {
    setState(() {
      _editingId[node.id] = node.label;
      _editController.text = node.label;
    });
  }

  void _commitRename(TreeNode node) {
    final newLabel = _editController.text.trim();
    if (newLabel.isNotEmpty && newLabel != node.label) {
      widget.controller.onNodeRenamed(node, newLabel);
    }
    setState(() => _editingId.remove(node.id));
  }

  void _showContextMenu(TreeNode node, Offset position) {
    if (node.contextMenuItems.isEmpty) return;

    final items = <PopupMenuEntry<ContextMenuItem>>[];
    for (final item in node.contextMenuItems) {
      if (item.isDivider) {
        items.add(const PopupMenuDivider());
      } else {
        items.add(PopupMenuItem<ContextMenuItem>(
          value: item,
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 16),
                const SizedBox(width: 8),
              ],
              Text(item.label),
            ],
          ),
        ));
      }
    }

    showMenu<ContextMenuItem>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: items,
    ).then((selected) {
      if (selected != null) {
        widget.controller.onContextMenuAction(node, selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final theme = FlutterLaneTheme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.header != null) widget.header!,
            if (widget.showToolbar) _buildToolbar(theme),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: widget.controller.rootNodes.length,
                itemBuilder: (context, index) {
                  return _buildNode(
                    widget.controller.rootNodes[index],
                    depth: 0,
                    theme: theme,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(FlutterLaneThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, size: 16),
            tooltip: 'New Folder',
            onPressed: () => widget.controller.onNewNode(null, isFile: false),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
          IconButton(
            icon: const Icon(Icons.note_add_outlined, size: 16),
            tooltip: 'New File',
            onPressed: () => widget.controller.onNewNode(null, isFile: true),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(
    TreeNode node, {
    required int depth,
    required FlutterLaneThemeData theme,
  }) {
    final isExpanded = _expanded[node.id] ?? false;
    final isEditing = _editingId.containsKey(node.id);
    final indent = depth * widget.indentSize;

    return GestureDetector(
      onTap: () {
        if (node.isFolder) {
          _toggleExpand(node);
        }
        widget.controller.onNodeTap(node);
      },
      onSecondaryTapUp: (details) {
        _showContextMenu(node, details.globalPosition);
      },
      child: Container(
        height: widget.rowHeight,
        padding: EdgeInsets.only(left: 8 + indent, right: 8),
        child: Row(
          children: [
            if (node.isFolder)
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                size: 16,
                color: theme.tabInactiveTextColor,
              )
            else
              const SizedBox(width: 16),
            const SizedBox(width: 2),
            Icon(
              node.icon ?? (node.isFolder
                  ? (isExpanded
                      ? Icons.folder_open
                      : Icons.folder)
                  : Icons.insert_drive_file),
              size: 16,
              color: node.isFolder
                  ? Colors.amber.shade600
                  : theme.tabInactiveTextColor,
            ),
            const SizedBox(width: 6),
            if (isEditing)
              Expanded(
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.enter) {
                        _commitRename(node);
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.escape) {
                        setState(() => _editingId.remove(node.id));
                      }
                    }
                  },
                  child: TextField(
                    controller: _editController
                      ..selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _editController.text.length,
                      ),
                    autofocus: true,
                    style: TextStyle(fontSize: 12, color: theme.tabActiveTextColor),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _commitRename(node),
                    onTapOutside: (_) => _commitRename(node),
                  ),
                ),
              )
            else
              Expanded(
                child: Text(
                  node.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.tabActiveTextColor,
                  ),
                ),
              ),
            if (node.badgeCount != null && node.badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.tabActiveBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${node.badgeCount}',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.tabActiveTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
