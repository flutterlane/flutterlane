import 'layout_state.dart';
import '../theme/flutter_lane_theme.dart';
import '../utils/id.dart';

/// A fully isolated workspace containing its own layouts, theme, and view registry.
///
/// Each [Workspace] is an independent unit — no state is shared between workspaces.
/// The app creates one [FlutterLaneManager] per workspace and swaps them in the
/// widget tree to switch contexts.
class Workspace {
  /// Unique workspace identifier (UUID or application-defined slug).
  final String workspaceId;

  /// Human-readable workspace name.
  String workspaceName;

  /// The theme type for this workspace.
  FlutterLaneThemeType themeType;

  /// All layout snapshots belonging to this workspace.
  List<LayoutState> layouts;

  /// The ID of the currently active layout within this workspace.
  String? activeLayoutId;

  Workspace({
    String? workspaceId,
    this.workspaceName = 'Untitled',
    this.themeType = FlutterLaneThemeType.light,
    List<LayoutState>? layouts,
    this.activeLayoutId,
  })  : workspaceId = workspaceId ?? generateId(),
        layouts = layouts ?? [];

  /// Returns the active layout snapshot, or the first layout if none is marked active.
  LayoutState? get activeLayout {
    if (layouts.isEmpty) return null;
    return layouts.firstWhere(
      (l) => l.snapshotId == activeLayoutId,
      orElse: () => layouts.first,
    );
  }

  /// Creates a workspace with a system-default layout.
  factory Workspace.defaults({
    String? workspaceId,
    String workspaceName = 'Default',
    FlutterLaneThemeType themeType = FlutterLaneThemeType.light,
  }) {
    final defaultLayout = LayoutState.systemDefault();
    return Workspace(
      workspaceId: workspaceId,
      workspaceName: workspaceName,
      themeType: themeType,
      layouts: [defaultLayout],
      activeLayoutId: defaultLayout.snapshotId,
    );
  }

  Map<String, dynamic> toJson() => {
        'workspaceId': workspaceId,
        'workspaceName': workspaceName,
        'themeType': themeType.name,
        'activeLayoutId': activeLayoutId,
      };

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      workspaceId: json['workspaceId'] as String?,
      workspaceName: json['workspaceName'] as String? ?? 'Untitled',
      themeType: FlutterLaneThemeType.values.firstWhere(
        (e) => e.name == json['themeType'],
        orElse: () => FlutterLaneThemeType.light,
      ),
      activeLayoutId: json['activeLayoutId'] as String?,
    );
  }
}
