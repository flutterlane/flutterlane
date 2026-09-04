import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Provides the canonical storage paths for the `.flutterlane/` directory.
///
/// Supports both global paths (for `workspaces.json`) and workspace-scoped
/// paths (for per-workspace layouts and theme settings).
class StoragePath {
  StoragePath._();

  /// The directory name used for all FlutterLane persistence.
  static const String dirName = '.flutterlane';

  /// Cached base directory path (set during [init]).
  static String _baseDir = '';

  /// Returns the base directory (e.g. `<appWorkDir>/.flutterlane/`).
  static String get baseDir => _baseDir;

  /// Must be called once at engine startup to resolve the working directory.
  static Future<void> init() async {
    if (kIsWeb) {
      _baseDir = '';
      return;
    }
    final appDir = await getApplicationDocumentsDirectory();
    _baseDir = '${appDir.parent.path}/$dirName';
    final dir = Directory(_baseDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  // ── Global paths ──

  /// Path to the workspaces registry JSON file.
  static String get workspacesFile => '$_baseDir/workspaces.json';

  /// Path to the engine config file.
  static String get engineConfigFile => '$_baseDir/engine_config.json';

  // ── Workspace-scoped paths ──

  /// Returns the directory for a specific workspace.
  static String workspaceDir(String workspaceId) =>
      '$_baseDir/workspaces/$workspaceId';

  /// Returns the layouts file for a specific workspace.
  static String workspaceLayoutsFile(String workspaceId) =>
      '${workspaceDir(workspaceId)}/layouts.json';

  /// Returns the theme settings file for a specific workspace.
  static String workspaceThemeFile(String workspaceId) =>
      '${workspaceDir(workspaceId)}/theme_settings.json';

  /// Ensures the base directory exists.
  static Future<void> ensureExists() async {
    final dir = Directory(_baseDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Ensures the directory for a specific workspace exists.
  static Future<void> ensureWorkspaceExists(String workspaceId) async {
    final dir = Directory(workspaceDir(workspaceId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
}
