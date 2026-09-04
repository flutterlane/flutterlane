/// FlutterLane — A professional IDE-level layered layout engine for Flutter desktop.
///
/// Three-layer swimlane architecture with drag-and-drop, resize,
/// multi-layout snapshots, and pluggable registry.
library flutterlane;

// ── Core ──
export 'src/core/flutter_lane_manager.dart';

// ── Utils ──
export 'src/utils/id.dart';

// ── Models ──
export 'src/models/workspace.dart';
export 'src/models/layout_state.dart';
export 'src/models/swimlane.dart';
export 'src/models/section.dart';
export 'src/models/pane.dart';
export 'src/models/view_instance.dart';
export 'src/models/chrome_menu_item.dart';
export 'src/models/chrome_header_action.dart';

// ── Theme ──
export 'src/theme/flutter_lane_theme.dart';
export 'src/theme/theme_manager.dart';

// ── Registry ──
export 'src/registry/flutter_lane_registry.dart';

// ── Storage ──
export 'src/storage/storage_path.dart';
export 'src/storage/layout_storage.dart';

// ── Widgets ──
export 'src/widgets/flutter_lane_chrome.dart';
export 'src/widgets/flutter_lane_workbench.dart';
export 'src/widgets/swimlane/swimlane_widget.dart';
export 'src/widgets/section/section_widget.dart';
export 'src/widgets/pane/pane_widget.dart';
export 'src/widgets/tab_bar/window_tab_bar.dart';

// ── Default Views ──
export 'src/views/explorer/tree_node.dart';
export 'src/views/explorer/explorer_controller.dart';
export 'src/views/explorer/explorer_tree_view.dart';
export 'src/views/markdown/markdown_editor_preview.dart';
export 'src/views/markdown/markdown_renderer.dart';
export 'src/views/markdown/markdown_theme.dart';
export 'src/views/markdown/extensions/callout_syntax.dart';
export 'src/views/ai_box/chat_controller.dart';
export 'src/views/ai_box/ai_chat_box.dart';

// ── Interactions ──
export 'src/interactions/hover/add_swimlane_hot_zone.dart';
export 'src/interactions/resize/resize_handle.dart';
export 'src/interactions/drag/drag_target_info.dart';
