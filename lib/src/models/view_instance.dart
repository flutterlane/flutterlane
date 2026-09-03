/// Business view instance with cached state.
///
/// Represents a concrete business view attached to a Pane,
/// carrying its type identifier, business context, and serializable state.
class ViewInstance {
  /// The registered view type identifier.
  final String viewTypeId;

  /// Business context string (e.g. project path, workspace ID).
  final String businessContext;

  /// Serializable view state map for state caching across tab switches.
  final Map<String, dynamic> viewState;

  const ViewInstance({
    required this.viewTypeId,
    this.businessContext = '',
    this.viewState = const {},
  });

  ViewInstance copyWith({
    String? viewTypeId,
    String? businessContext,
    Map<String, dynamic>? viewState,
  }) {
    return ViewInstance(
      viewTypeId: viewTypeId ?? this.viewTypeId,
      businessContext: businessContext ?? this.businessContext,
      viewState: viewState ?? this.viewState,
    );
  }

  Map<String, dynamic> toJson() => {
        'viewTypeId': viewTypeId,
        'businessContext': businessContext,
        'viewState': viewState,
      };

  factory ViewInstance.fromJson(Map<String, dynamic> json) {
    return ViewInstance(
      viewTypeId: json['viewTypeId'] as String? ?? '',
      businessContext: json['businessContext'] as String? ?? '',
      viewState: Map<String, dynamic>.from(json['viewState'] as Map? ?? {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewInstance &&
          runtimeType == other.runtimeType &&
          viewTypeId == other.viewTypeId &&
          businessContext == other.businessContext;

  @override
  int get hashCode => Object.hash(viewTypeId, businessContext);
}
