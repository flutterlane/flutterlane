import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Provides the canonical storage paths for the `.flutterlane/` directory.
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
      // Web has no native documents directory; persistence is best-effort.
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

  /// Path to the main layouts JSON file.
  static String get layoutsFile => '$_baseDir/layouts.json';

  /// Path to the theme settings file.
  static String get themeSettingsFile => '$_baseDir/theme_settings.json';

  /// Path to the engine config file.
  static String get engineConfigFile => '$_baseDir/engine_config.json';

  /// Ensures the base directory exists.
  static Future<void> ensureExists() async {
    final dir = Directory(_baseDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
}
