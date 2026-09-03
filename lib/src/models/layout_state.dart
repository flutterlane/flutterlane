import 'swimlane.dart';
import 'section.dart';
import '../utils/id.dart';

/// Top-level layout snapshot model.
///
/// Represents a complete, serializable layout configuration that can be
/// persisted locally as JSON. Only one LayoutState is active at any time.
class LayoutState {
  /// Unique snapshot identifier (UUID).
  final String snapshotId;

  /// User-defined layout name.
  String layoutName;

  /// Whether this is the system-default layout (immutable, undeletable).
  final bool isSystemDefault;

  /// Whether this is the currently active layout.
  bool isCurrentActive;

  /// Creation timestamp (milliseconds since epoch).
  final int createTime;

  /// Last update timestamp (milliseconds since epoch).
  int updateTime;

  /// The full layout structure: ordered list of swimlanes.
  List<Swimlane> swimlanes;

  LayoutState({
    String? snapshotId,
    this.layoutName = 'Default',
    this.isSystemDefault = false,
    this.isCurrentActive = false,
    int? createTime,
    int? updateTime,
    List<Swimlane>? swimlanes,
  })  : snapshotId = snapshotId ?? generateId(),
        createTime = createTime ?? DateTime.now().millisecondsSinceEpoch,
        updateTime = updateTime ?? DateTime.now().millisecondsSinceEpoch,
        swimlanes = swimlanes ?? [];

  /// Touch update time to now.
  void touch() {
    updateTime = DateTime.now().millisecondsSinceEpoch;
  }

  /// Deep-clones this layout state.
  LayoutState clone() {
    return LayoutState(
      snapshotId: snapshotId,
      layoutName: layoutName,
      isSystemDefault: isSystemDefault,
      isCurrentActive: isCurrentActive,
      createTime: createTime,
      updateTime: updateTime,
      swimlanes: swimlanes.map((s) => Swimlane.fromJson(s.toJson())).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'snapshotId': snapshotId,
        'layoutName': layoutName,
        'isSystemDefault': isSystemDefault,
        'isCurrentActive': isCurrentActive,
        'createTime': createTime,
        'updateTime': updateTime,
        'swimlanes': swimlanes.map((s) => s.toJson()).toList(),
      };

  factory LayoutState.fromJson(Map<String, dynamic> json) {
    return LayoutState(
      snapshotId: json['snapshotId'] as String?,
      layoutName: json['layoutName'] as String? ?? 'Default',
      isSystemDefault: json['isSystemDefault'] as bool? ?? false,
      isCurrentActive: json['isCurrentActive'] as bool? ?? false,
      createTime: json['createTime'] as int?,
      updateTime: json['updateTime'] as int?,
      swimlanes: (json['swimlanes'] as List?)
              ?.map((e) => Swimlane.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Adds a swimlane at the given index, or at the end if index is null.
  void addSwimlane(Swimlane swimlane, {int? index}) {
    if (index != null && index >= 0 && index <= swimlanes.length) {
      swimlanes.insert(index, swimlane);
    } else {
      swimlanes.add(swimlane);
    }
  }

  /// Removes a swimlane by ID.
  Swimlane? removeSwimlane(String swimlaneId) {
    final index = swimlanes.indexWhere((s) => s.id == swimlaneId);
    if (index == -1) return null;
    return swimlanes.removeAt(index);
  }

  /// Creates the built-in system-default layout with one swimlane and one placeholder section.
  factory LayoutState.systemDefault() {
    final swimlane = Swimlane(sections: [Section.placeholder()]);
    return LayoutState(
      layoutName: 'Default',
      isSystemDefault: true,
      isCurrentActive: true,
      swimlanes: [swimlane],
    );
  }
}
