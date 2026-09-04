import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'flutter_lane_theme.dart';
import '../storage/storage_path.dart';

/// Manages the active FlutterLane theme with persistence and system-adaptive support.
///
/// Theme state is scoped to a specific workspace. Each workspace has its own
/// theme settings file under `.flutterlane/workspaces/{workspaceId}/`.
class ThemeManager extends ChangeNotifier {
  final String workspaceId;

  FlutterLaneThemeType _currentType = FlutterLaneThemeType.light;
  bool _followSystem = true;

  ThemeManager({required this.workspaceId});

  FlutterLaneThemeType get currentType => _currentType;
  FlutterLaneThemeData get currentTheme =>
      FlutterLaneThemeData.fromType(_currentType);
  bool get followSystem => _followSystem;

  /// Initializes the manager by loading persisted settings.
  Future<void> init() async {
    await _loadSettings();
  }

  /// Switches to the given theme type and persists.
  Future<void> setTheme(FlutterLaneThemeType type) async {
    if (_currentType == type) return;
    _currentType = type;
    notifyListeners();
    await _saveSettings();
  }

  /// Cycles through light → dark → pure → light …
  Future<void> cycleTheme() async {
    final next = FlutterLaneThemeType.values[
        (_currentType.index + 1) % FlutterLaneThemeType.values.length];
    await setTheme(next);
  }

  /// Toggles system-adaptive mode on/off.
  Future<void> setFollowSystem(bool value) async {
    if (_followSystem == value) return;
    _followSystem = value;
    notifyListeners();
    await _saveSettings();
  }

  /// Adapts theme to system brightness. Call from a WidgetsApp/BrightnessNotifier.
  Future<void> adaptToSystem(Brightness brightness) async {
    if (!_followSystem) return;
    final target = brightness == Brightness.dark
        ? FlutterLaneThemeType.dark
        : FlutterLaneThemeType.light;
    if (_currentType != target) {
      _currentType = target;
      notifyListeners();
      await _saveSettings();
    }
  }

  // ── Persistence ──

  File get _settingsFile =>
      File(StoragePath.workspaceThemeFile(workspaceId));

  Future<void> _loadSettings() async {
    try {
      final file = _settingsFile;
      if (await file.exists()) {
        final json =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        _currentType = FlutterLaneThemeType.values.firstWhere(
          (e) => e.name == json['themeType'],
          orElse: () => FlutterLaneThemeType.light,
        );
        _followSystem = json['followSystem'] as bool? ?? true;
        notifyListeners();
      }
    } catch (_) {
      // Ignore corrupted settings; keep defaults.
    }
  }

  Future<void> _saveSettings() async {
    try {
      await StoragePath.ensureWorkspaceExists(workspaceId);
      final file = _settingsFile;
      await file.writeAsString(jsonEncode({
        'themeType': _currentType.name,
        'followSystem': _followSystem,
      }));
    } catch (_) {
      // Best-effort persistence; silently ignore on web/desktop sandbox.
    }
  }
}
