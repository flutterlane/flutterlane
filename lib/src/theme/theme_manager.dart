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
/// Supports both built-in themes (light, dark, pure) and a registry of named
/// custom themes via [registerCustomTheme] / [switchToCustomTheme].
class ThemeManager extends ChangeNotifier {
  final String workspaceId;

  FlutterLaneThemeType _currentType = FlutterLaneThemeType.light;

  /// Registry of named custom themes: id → theme data.
  final Map<String, FlutterLaneThemeData> _customThemes = {};

  /// The ID of the currently active custom theme, or null if using built-in.
  String? _activeCustomThemeId;

  bool _followSystem = true;

  ThemeManager({required this.workspaceId});

  FlutterLaneThemeType get currentType => _currentType;

  /// Returns the active theme data. Prefers the active custom theme if set,
  /// otherwise falls back to the built-in theme for [_currentType].
  FlutterLaneThemeData get currentTheme {
    if (_activeCustomThemeId != null &&
        _customThemes.containsKey(_activeCustomThemeId)) {
      return _customThemes[_activeCustomThemeId]!;
    }
    return FlutterLaneThemeData.fromType(_currentType);
  }

  bool get followSystem => _followSystem;

  /// Whether any custom theme is currently active.
  bool get hasCustomTheme => _activeCustomThemeId != null;

  /// The ID of the currently active custom theme, or null.
  String? get activeCustomThemeId => _activeCustomThemeId;

  /// All registered custom themes (unmodifiable view).
  Map<String, FlutterLaneThemeData> get allCustomThemes =>
      Map.unmodifiable(_customThemes);

  /// Initializes the manager by loading persisted settings.
  Future<void> init() async {
    await _loadSettings();
  }

  // ── Built-in theme switching ──

  /// Switches to the given built-in theme type and persists.
  /// Clears any active custom theme.
  Future<void> setTheme(FlutterLaneThemeType type) async {
    _activeCustomThemeId = null;
    if (_currentType == type) return;
    _currentType = type;
    notifyListeners();
    await _saveSettings();
  }

  // ── Custom theme registry ──

  /// Registers a named custom theme. If [id] already exists, it is overwritten.
  Future<void> registerCustomTheme(
      String id, FlutterLaneThemeData theme) async {
    _customThemes[id] = theme;
    notifyListeners();
    await _saveSettings();
  }

  /// Removes a registered custom theme.
  /// If it was the active theme, reverts to the built-in theme.
  Future<void> unregisterCustomTheme(String id) async {
    if (!_customThemes.containsKey(id)) return;
    _customThemes.remove(id);
    if (_activeCustomThemeId == id) {
      _activeCustomThemeId = null;
    }
    notifyListeners();
    await _saveSettings();
  }

  /// Activates a previously registered custom theme by ID.
  /// The ID must exist in the registry; otherwise this is a no-op.
  Future<void> switchToCustomTheme(String id) async {
    if (!_customThemes.containsKey(id)) return;
    if (_activeCustomThemeId == id) return;
    _activeCustomThemeId = id;
    notifyListeners();
    await _saveSettings();
  }

  /// Returns a registered custom theme by ID, or null.
  FlutterLaneThemeData? getCustomTheme(String id) => _customThemes[id];

  /// Registers and immediately activates a custom theme (convenience shorthand).
  ///
  /// ```dart
  /// await themeManager.setCustomTheme('my-brand', const FlutterLaneThemeData(...));
  /// ```
  Future<void> setCustomTheme(String id, FlutterLaneThemeData theme) async {
    _customThemes[id] = theme;
    _activeCustomThemeId = id;
    notifyListeners();
    await _saveSettings();
  }

  /// Clears the active custom theme, reverting to the built-in theme
  /// for the current [_currentType]. Does not remove the theme from the registry.
  Future<void> clearCustomTheme() async {
    if (_activeCustomThemeId == null) return;
    _activeCustomThemeId = null;
    notifyListeners();
    await _saveSettings();
  }

  /// Cycles through all available themes: light → dark → pure → custom₁ → custom₂ → … → light.
  ///
  /// If a custom theme is active, clears it first and starts cycling from
  /// the current built-in type.
  Future<void> cycleTheme() async {
    final builtInCount = FlutterLaneThemeType.values.length;
    final customCount = _customThemes.length;
    final total = builtInCount + customCount;

    if (total == 0) return;

    // Determine the effective position before cycling.
    int currentPos;
    if (_activeCustomThemeId != null) {
      // Currently on a custom theme — find its position.
      final customIds = _customThemes.keys.toList();
      final customIdx = customIds.indexOf(_activeCustomThemeId!);
      _activeCustomThemeId = null;
      currentPos = builtInCount + (customIdx >= 0 ? customIdx : 0);
    } else {
      currentPos = _currentType.index;
    }

    final nextPos = (currentPos + 1) % total;

    if (nextPos < builtInCount) {
      // Next is a built-in theme.
      final next = FlutterLaneThemeType.values[nextPos];
      if (_currentType == next && _activeCustomThemeId == null) return;
      _currentType = next;
      notifyListeners();
      await _saveSettings();
    } else {
      // Next is a custom theme.
      final customIds = _customThemes.keys.toList();
      final customIndex = nextPos - builtInCount;
      if (customIndex < customIds.length) {
        _activeCustomThemeId = customIds[customIndex];
        notifyListeners();
        await _saveSettings();
      }
    }
  }

  // ── System adaptive ──

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

        // Restore active custom theme ID.
        _activeCustomThemeId = json['activeCustomThemeId'] as String?;

        // Restore custom themes registry.
        final customThemesJson = json['customThemes'];
        if (customThemesJson is Map<String, dynamic>) {
          _customThemes.clear();
          for (final entry in customThemesJson.entries) {
            _customThemes[entry.key] = _themeDataFromJson(
              entry.value as Map<String, dynamic>,
            );
          }
        }

        // Validate that the active ID still exists.
        if (_activeCustomThemeId != null &&
            !_customThemes.containsKey(_activeCustomThemeId)) {
          _activeCustomThemeId = null;
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
        'activeCustomThemeId': _activeCustomThemeId,
        'customThemes': <String, dynamic>{
          for (final entry in _customThemes.entries)
            entry.key: _themeDataToJson(entry.value),
        },
      };
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
