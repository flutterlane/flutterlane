import 'dart:convert';
import 'dart:io';

import '../models/layout_state.dart';
import 'storage_path.dart';

/// Handles local JSON persistence of LayoutState snapshots.
///
/// All layout snapshots are stored as a single JSON array in `.flutterlane/layouts.json`.
/// Changes are auto-saved (covered) on every layout mutation.
class LayoutStorage {
  /// Reads all stored layout states from disk.
  Future<List<LayoutState>> readAll() async {
    try {
      final file = File(StoragePath.layoutsFile);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];
      final list = jsonDecode(content) as List;
      return list
          .map((e) => LayoutState.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Writes all layout states to disk (full overwrite).
  Future<void> writeAll(List<LayoutState> layouts) async {
    await StoragePath.ensureExists();
    final file = File(StoragePath.layoutsFile);
    final json = layouts.map((l) => l.toJson()).toList();
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(json),
    );
  }

  /// Reads the ID of the currently active layout.
  Future<String?> readActiveId() async {
    try {
      final file = File(StoragePath.layoutsFile);
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      if (content.trim().isEmpty) return null;
      final list = jsonDecode(content) as List;
      for (final item in list) {
        if (item['isCurrentActive'] == true) {
          return item['snapshotId'] as String?;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
