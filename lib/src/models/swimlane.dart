import 'section.dart';
import '../utils/id.dart';

/// A horizontal column container in the layout.
///
/// Swimlanes are the top-level containers arranged horizontally.
/// Each Swimlane holds one or more Sections stacked vertically.
class Swimlane {
  /// Unique swimlane identifier.
  final String id;

  /// Flex factor for horizontal sizing. Controls width distribution
  /// among swimlanes using the flex layout system.
  double flex;

  /// Minimum width in pixels. Resize operations will not go below this.
  double minWidth;

  /// Fixed width in pixels; when set, this swimlane cannot be resized.
  final double? fixedWidth;

  /// Whether users may remove this swimlane.
  final bool canClose;

  /// Ordered list of sections within this swimlane.
  List<Section> sections;

  Swimlane({
    String? id,
    this.flex = 1.0,
    this.minWidth = 120.0,
    this.fixedWidth,
    this.canClose = true,
    List<Section>? sections,
  })  : id = id ?? generateId(),
        sections = sections ?? [];

  /// Ensures at least one placeholder section exists.
  /// Call after removing all sections to prevent layout collapse.
  void ensurePlaceholder() {
    if (sections.isEmpty) {
      sections.add(Section.placeholder());
    }
  }

  /// Removes a section by ID. Auto-injects placeholder if empty.
  Section? removeSection(String sectionId) {
    final index = sections.indexWhere((s) => s.sectionId == sectionId);
    if (index == -1) return null;
    final removed = sections.removeAt(index);
    ensurePlaceholder();
    return removed;
  }

  /// Adds a section at the given index, or at the end if index is null.
  void addSection(Section section, {int? index}) {
    if (index != null && index >= 0 && index <= sections.length) {
      sections.insert(index, section);
    } else {
      sections.add(section);
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'flex': flex,
        'minWidth': minWidth,
        'fixedWidth': fixedWidth,
        'canClose': canClose,
        'sections': sections.map((s) => s.toJson()).toList(),
      };

  factory Swimlane.fromJson(Map<String, dynamic> json) {
    return Swimlane(
      id: json['id'] as String?,
      flex: (json['flex'] as num?)?.toDouble() ?? 1.0,
      minWidth: (json['minWidth'] as num?)?.toDouble() ?? 120.0,
      fixedWidth: (json['fixedWidth'] as num?)?.toDouble(),
        canClose: json['canClose'] as bool? ?? true,
      sections: (json['sections'] as List?)
              ?.map((e) => Section.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
