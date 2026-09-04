import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'flutter_lane_theme.dart';
import '../storage/storage_path.dart';

/// Manages the active FlutterLane theme with persistence and system-adaptive support.
///
/// Theme state is scoped to a specific workspace. Each workspace has its own
/// theme settings file under `.flutterlane/workspaces/{workspaceId}/`.
///
/// Supports both built-in themes (light, dark, pure) and fully custom themes
/// via [setCustomTheme].
class ThemeManager extends ChangeNotifier {
  final String workspaceId;

  FlutterLaneThemeType _currentType = FlutterLaneThemeType.light;
  FlutterLaneThemeData? _customThemeData;
  bool _followSystem = true;

  ThemeManager({required this.workspaceId});

  FlutterLaneThemeType get currentType => _currentType;

  /// Returns the active theme data. Prefers [_customThemeData] if set,
  /// otherwise falls back to the built-in theme for [_currentType].
  FlutterLaneThemeData get currentTheme =>
      _customThemeData ?? FlutterLaneThemeData.fromType(_currentType);

  bool get followSystem => _followSystem;
  bool get hasCustomTheme => _customThemeData != null;

  /// Initializes the manager by loading persisted settings.
  Future<void> init() async {
    await _loadSettings();
  }

  /// Switches to the given built-in theme type and persists.
  /// Clears any custom theme override.
  Future<void> setTheme(FlutterLaneThemeType type) async {
    _customThemeData = null;
    if (_currentType == type) return;
    _currentType = type;
    notifyListeners();
    await _saveSettings();
  }

  /// Applies a fully custom theme. Overrides the built-in theme until
  /// [clearCustomTheme] is called or [setTheme] is invoked.
  Future<void> setCustomTheme(FlutterLaneThemeData theme) async {
    _customThemeData = theme;
    notifyListeners();
    await _saveSettings();
  }

  /// Clears the custom theme override, reverting to the built-in theme
  /// for the current [_currentType].
  Future<void> clearCustomTheme() async {
    if (_customThemeData == null) return;
    _customThemeData = null;
    notifyListeners();
    await _saveSettings();
  }

  /// Cycles through light → dark → pure → light …
  /// If a custom theme is active, clears it first and starts cycling from
  /// the current built-in type.
  Future<void> cycleTheme() async {
    if (_customThemeData != null) {
      _customThemeData = null;
    }
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

        // Restore custom theme if persisted.
        if (json['customTheme'] != null) {
          _customThemeData =
              _themeDataFromJson(json['customTheme'] as Map<String, dynamic>);
        }

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
      final data = <String, dynamic>{
        'themeType': _currentType.name,
        'followSystem': _followSystem,
      };
      if (_customThemeData != null) {
        data['customTheme'] = _themeDataToJson(_customThemeData!);
      }
      await file.writeAsString(jsonEncode(data));
    } catch (_) {
      // Best-effort persistence; silently ignore on web/desktop sandbox.
    }
  }

  // ── Color serialization helpers ──

  static String _colorToHex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0')}';

  static Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Map<String, dynamic> _themeDataToJson(FlutterLaneThemeData t) => {
        'swimlaneBackground': _colorToHex(t.swimlaneBackground),
        'swimlaneDivider': _colorToHex(t.swimlaneDivider),
        'sectionBackground': _colorToHex(t.sectionBackground),
        'sectionHeaderBackground': _colorToHex(t.sectionHeaderBackground),
        'sectionHeaderTextColor': _colorToHex(t.sectionHeaderTextColor),
        'sectionBorderColor': _colorToHex(t.sectionBorderColor),
        'tabBarBackground': _colorToHex(t.tabBarBackground),
        'tabActiveBackground': _colorToHex(t.tabActiveBackground),
        'tabActiveTextColor': _colorToHex(t.tabActiveTextColor),
        'tabInactiveTextColor': _colorToHex(t.tabInactiveTextColor),
        'tabHoverBackground': _colorToHex(t.tabHoverBackground),
        'tabBorderColor': _colorToHex(t.tabBorderColor),
        'paneContentBackground': _colorToHex(t.paneContentBackground),
        'resizeHandleColor': _colorToHex(t.resizeHandleColor),
        'resizeHandleHoverColor': _colorToHex(t.resizeHandleHoverColor),
        'hoverZoneColor': _colorToHex(t.hoverZoneColor),
        'hoverZoneActiveColor': _colorToHex(t.hoverZoneActiveColor),
        'dragPlaceholderColor': _colorToHex(t.dragPlaceholderColor),
        'dragPreviewColor': _colorToHex(t.dragPreviewColor),
        'tooltipBackground': _colorToHex(t.tooltipBackground),
        'tooltipTextColor': _colorToHex(t.tooltipTextColor),
        'statusBarBackground': _colorToHex(t.statusBarBackground),
        'statusBarTextColor': _colorToHex(t.statusBarTextColor),
        'headerBarBackground': _colorToHex(t.headerBarBackground),
        'headerBarTextColor': _colorToHex(t.headerBarTextColor),
        'scrollbarThumbColor': _colorToHex(t.scrollbarThumbColor),
        'scrollbarTrackColor': _colorToHex(t.scrollbarTrackColor),
      };

  static FlutterLaneThemeData _themeDataFromJson(Map<String, dynamic> j) =>
      FlutterLaneThemeData(
        swimlaneBackground: _colorFromHex(j['swimlaneBackground'] as String),
        swimlaneDivider: _colorFromHex(j['swimlaneDivider'] as String),
        sectionBackground: _colorFromHex(j['sectionBackground'] as String),
        sectionHeaderBackground:
            _colorFromHex(j['sectionHeaderBackground'] as String),
        sectionHeaderTextColor:
            _colorFromHex(j['sectionHeaderTextColor'] as String),
        sectionBorderColor: _colorFromHex(j['sectionBorderColor'] as String),
        tabBarBackground: _colorFromHex(j['tabBarBackground'] as String),
        tabActiveBackground: _colorFromHex(j['tabActiveBackground'] as String),
        tabActiveTextColor: _colorFromHex(j['tabActiveTextColor'] as String),
        tabInactiveTextColor:
            _colorFromHex(j['tabInactiveTextColor'] as String),
        tabHoverBackground: _colorFromHex(j['tabHoverBackground'] as String),
        tabBorderColor: _colorFromHex(j['tabBorderColor'] as String),
        paneContentBackground:
            _colorFromHex(j['paneContentBackground'] as String),
        resizeHandleColor: _colorFromHex(j['resizeHandleColor'] as String),
        resizeHandleHoverColor:
            _colorFromHex(j['resizeHandleHoverColor'] as String),
        hoverZoneColor: _colorFromHex(j['hoverZoneColor'] as String),
        hoverZoneActiveColor: _colorFromHex(j['hoverZoneActiveColor'] as String),
        dragPlaceholderColor:
            _colorFromHex(j['dragPlaceholderColor'] as String),
        dragPreviewColor: _colorFromHex(j['dragPreviewColor'] as String),
        tooltipBackground: _colorFromHex(j['tooltipBackground'] as String),
        tooltipTextColor: _colorFromHex(j['tooltipTextColor'] as String),
        statusBarBackground: _colorFromHex(j['statusBarBackground'] as String),
        statusBarTextColor: _colorFromHex(j['statusBarTextColor'] as String),
        headerBarBackground: _colorFromHex(j['headerBarBackground'] as String),
        headerBarTextColor: _colorFromHex(j['headerBarTextColor'] as String),
        scrollbarThumbColor: _colorFromHex(j['scrollbarThumbColor'] as String),
        scrollbarTrackColor: _colorFromHex(j['scrollbarTrackColor'] as String),
      );
}
