import 'view_instance.dart';

/// A tab carrier within a Section, binding a business view instance.
///
/// Panes are the leaf nodes of the layout tree. Each Pane must always
/// carry a valid ViewInstance — empty Panes are prohibited by the engine.
class Pane {
  /// Unique pane identifier.
  final String paneId;

  /// The business view instance bound to this pane.
  final ViewInstance viewInstance;

  const Pane({
    required this.paneId,
    required this.viewInstance,
  });

  Pane copyWith({
    String? paneId,
    ViewInstance? viewInstance,
  }) {
    return Pane(
      paneId: paneId ?? this.paneId,
      viewInstance: viewInstance ?? this.viewInstance,
    );
  }

  Map<String, dynamic> toJson() => {
        'paneId': paneId,
        'viewInstance': viewInstance.toJson(),
      };

  factory Pane.fromJson(Map<String, dynamic> json) {
    return Pane(
      paneId: json['paneId'] as String? ?? '',
      viewInstance: ViewInstance.fromJson(
          json['viewInstance'] as Map<String, dynamic>? ?? {}),
    );
  }
}
