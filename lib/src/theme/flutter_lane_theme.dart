import 'package:flutter/material.dart';

/// FlutterLane built-in theme identifier.
enum FlutterLaneThemeType {
  light,
  dark,
  pure,
}

/// Complete color/style specification for a FlutterLane theme.
///
/// Controls every visual aspect of the layout engine shell:
/// swimlane backgrounds, section panels, tab bars, resize splitters,
/// hover hot zones, drag previews, tooltips, status bar, etc.
class FlutterLaneThemeData {
  // ── Swimlane ──
  final Color swimlaneBackground;
  final Color swimlaneDivider;

  // ── Section ──
  final Color sectionBackground;
  final Color sectionHeaderBackground;
  final Color sectionHeaderTextColor;
  final Color sectionBorderColor;

  // ── Tab Bar ──
  final Color tabBarBackground;
  final Color tabActiveBackground;
  final Color tabActiveTextColor;
  final Color tabInactiveTextColor;
  final Color tabHoverBackground;
  final Color tabBorderColor;

  // ── Pane Content ──
  final Color paneContentBackground;

  // ── Resize Splitter ──
  final Color resizeHandleColor;
  final Color resizeHandleHoverColor;

  // ── Hover Hot Zone ──
  final Color hoverZoneColor;
  final Color hoverZoneActiveColor;

  // ── Drag ──
  final Color dragPlaceholderColor;
  final Color dragPreviewColor;

  // ── Tooltip / Popup ──
  final Color tooltipBackground;
  final Color tooltipTextColor;

  // ── Status Bar ──
  final Color statusBarBackground;
  final Color statusBarTextColor;

  // ── Header Bar ──
  final Color headerBarBackground;
  final Color headerBarTextColor;

  // ── Scrollbar ──
  final Color scrollbarThumbColor;
  final Color scrollbarTrackColor;

  const FlutterLaneThemeData({
    required this.swimlaneBackground,
    required this.swimlaneDivider,
    required this.sectionBackground,
    required this.sectionHeaderBackground,
    required this.sectionHeaderTextColor,
    required this.sectionBorderColor,
    required this.tabBarBackground,
    required this.tabActiveBackground,
    required this.tabActiveTextColor,
    required this.tabInactiveTextColor,
    required this.tabHoverBackground,
    required this.tabBorderColor,
    required this.paneContentBackground,
    required this.resizeHandleColor,
    required this.resizeHandleHoverColor,
    required this.hoverZoneColor,
    required this.hoverZoneActiveColor,
    required this.dragPlaceholderColor,
    required this.dragPreviewColor,
    required this.tooltipBackground,
    required this.tooltipTextColor,
    required this.statusBarBackground,
    required this.statusBarTextColor,
    required this.headerBarBackground,
    required this.headerBarTextColor,
    required this.scrollbarThumbColor,
    required this.scrollbarTrackColor,
  });

  /// Classic light theme — low saturation, high contrast for daytime use.
  static const light = FlutterLaneThemeData(
    swimlaneBackground: Color(0xFFF5F5F5),
    swimlaneDivider: Color(0xFFE0E0E0),
    sectionBackground: Color(0xFFFFFFFF),
    sectionHeaderBackground: Color(0xFFFAFAFA),
    sectionHeaderTextColor: Color(0xFF333333),
    sectionBorderColor: Color(0xFFE0E0E0),
    tabBarBackground: Color(0xFFF0F0F0),
    tabActiveBackground: Color(0xFFFFFFFF),
    tabActiveTextColor: Color(0xFF1A1A1A),
    tabInactiveTextColor: Color(0xFF757575),
    tabHoverBackground: Color(0xFFE8E8E8),
    tabBorderColor: Color(0xFFE0E0E0),
    paneContentBackground: Color(0xFFFFFFFF),
    resizeHandleColor: Color(0xFFD0D0D0),
    resizeHandleHoverColor: Color(0xFF90CAF9),
    hoverZoneColor: Color(0x202196F3),
    hoverZoneActiveColor: Color(0x602196F3),
    dragPlaceholderColor: Color(0x302196F3),
    dragPreviewColor: Color(0x8090CAF9),
    tooltipBackground: Color(0xFF333333),
    tooltipTextColor: Color(0xFFFFFFFF),
    statusBarBackground: Color(0xFFF0F0F0),
    statusBarTextColor: Color(0xFF555555),
    headerBarBackground: Color(0xFFFAFAFA),
    headerBarTextColor: Color(0xFF333333),
    scrollbarThumbColor: Color(0xFFBDBDBD),
    scrollbarTrackColor: Color(0x00000000),
  );

  /// Dark theme — deep background, minimal highlights for night-time coding.
  static const dark = FlutterLaneThemeData(
    swimlaneBackground: Color(0xFF1E1E1E),
    swimlaneDivider: Color(0xFF333333),
    sectionBackground: Color(0xFF252526),
    sectionHeaderBackground: Color(0xFF2D2D2D),
    sectionHeaderTextColor: Color(0xFFCCCCCC),
    sectionBorderColor: Color(0xFF3C3C3C),
    tabBarBackground: Color(0xFF252526),
    tabActiveBackground: Color(0xFF1E1E1E),
    tabActiveTextColor: Color(0xFFFFFFFF),
    tabInactiveTextColor: Color(0xFF858585),
    tabHoverBackground: Color(0xFF333333),
    tabBorderColor: Color(0xFF3C3C3C),
    paneContentBackground: Color(0xFF1E1E1E),
    resizeHandleColor: Color(0xFF424242),
    resizeHandleHoverColor: Color(0xFF5C6BC0),
    hoverZoneColor: Color(0x205C6BC0),
    hoverZoneActiveColor: Color(0x605C6BC0),
    dragPlaceholderColor: Color(0x305C6BC0),
    dragPreviewColor: Color(0x807986CB),
    tooltipBackground: Color(0xFF2D2D2D),
    tooltipTextColor: Color(0xFFCCCCCC),
    statusBarBackground: Color(0xFF007ACC),
    statusBarTextColor: Color(0xFFFFFFFF),
    headerBarBackground: Color(0xFF333333),
    headerBarTextColor: Color(0xFFCCCCCC),
    scrollbarThumbColor: Color(0xFF424242),
    scrollbarTrackColor: Color(0x00000000),
  );

  /// Pure/minimalist theme — low distraction, grayscale, no gradients.
  static const pure = FlutterLaneThemeData(
    swimlaneBackground: Color(0xFFFAFAFA),
    swimlaneDivider: Color(0xFFE8E8E8),
    sectionBackground: Color(0xFFFFFFFF),
    sectionHeaderBackground: Color(0xFFFCFCFC),
    sectionHeaderTextColor: Color(0xFF444444),
    sectionBorderColor: Color(0xFFE8E8E8),
    tabBarBackground: Color(0xFFF8F8F8),
    tabActiveBackground: Color(0xFFFFFFFF),
    tabActiveTextColor: Color(0xFF222222),
    tabInactiveTextColor: Color(0xFF999999),
    tabHoverBackground: Color(0xFFF0F0F0),
    tabBorderColor: Color(0xFFE8E8E8),
    paneContentBackground: Color(0xFFFFFFFF),
    resizeHandleColor: Color(0xFFE0E0E0),
    resizeHandleHoverColor: Color(0xFFBDBDBD),
    hoverZoneColor: Color(0x18000000),
    hoverZoneActiveColor: Color(0x40000000),
    dragPlaceholderColor: Color(0x20000000),
    dragPreviewColor: Color(0x60BDBDBD),
    tooltipBackground: Color(0xFF444444),
    tooltipTextColor: Color(0xFFFFFFFF),
    statusBarBackground: Color(0xFFF5F5F5),
    statusBarTextColor: Color(0xFF777777),
    headerBarBackground: Color(0xFFFCFCFC),
    headerBarTextColor: Color(0xFF444444),
    scrollbarThumbColor: Color(0xFFCCCCCC),
    scrollbarTrackColor: Color(0x00000000),
  );

  /// Returns the built-in theme for [type].
  static FlutterLaneThemeData fromType(FlutterLaneThemeType type) {
    switch (type) {
      case FlutterLaneThemeType.light:
        return light;
      case FlutterLaneThemeType.dark:
        return dark;
      case FlutterLaneThemeType.pure:
        return pure;
    }
  }

  /// Linearly interpolates between two themes for animations.
  static FlutterLaneThemeData lerp(
    FlutterLaneThemeData a,
    FlutterLaneThemeData b,
    double t,
  ) {
    return FlutterLaneThemeData(
      swimlaneBackground:
          Color.lerp(a.swimlaneBackground, b.swimlaneBackground, t)!,
      swimlaneDivider: Color.lerp(a.swimlaneDivider, b.swimlaneDivider, t)!,
      sectionBackground:
          Color.lerp(a.sectionBackground, b.sectionBackground, t)!,
      sectionHeaderBackground:
          Color.lerp(a.sectionHeaderBackground, b.sectionHeaderBackground, t)!,
      sectionHeaderTextColor:
          Color.lerp(a.sectionHeaderTextColor, b.sectionHeaderTextColor, t)!,
      sectionBorderColor:
          Color.lerp(a.sectionBorderColor, b.sectionBorderColor, t)!,
      tabBarBackground: Color.lerp(a.tabBarBackground, b.tabBarBackground, t)!,
      tabActiveBackground:
          Color.lerp(a.tabActiveBackground, b.tabActiveBackground, t)!,
      tabActiveTextColor:
          Color.lerp(a.tabActiveTextColor, b.tabActiveTextColor, t)!,
      tabInactiveTextColor:
          Color.lerp(a.tabInactiveTextColor, b.tabInactiveTextColor, t)!,
      tabHoverBackground:
          Color.lerp(a.tabHoverBackground, b.tabHoverBackground, t)!,
      tabBorderColor: Color.lerp(a.tabBorderColor, b.tabBorderColor, t)!,
      paneContentBackground:
          Color.lerp(a.paneContentBackground, b.paneContentBackground, t)!,
      resizeHandleColor:
          Color.lerp(a.resizeHandleColor, b.resizeHandleColor, t)!,
      resizeHandleHoverColor:
          Color.lerp(a.resizeHandleHoverColor, b.resizeHandleHoverColor, t)!,
      hoverZoneColor: Color.lerp(a.hoverZoneColor, b.hoverZoneColor, t)!,
      hoverZoneActiveColor:
          Color.lerp(a.hoverZoneActiveColor, b.hoverZoneActiveColor, t)!,
      dragPlaceholderColor:
          Color.lerp(a.dragPlaceholderColor, b.dragPlaceholderColor, t)!,
      dragPreviewColor: Color.lerp(a.dragPreviewColor, b.dragPreviewColor, t)!,
      tooltipBackground:
          Color.lerp(a.tooltipBackground, b.tooltipBackground, t)!,
      tooltipTextColor: Color.lerp(a.tooltipTextColor, b.tooltipTextColor, t)!,
      statusBarBackground:
          Color.lerp(a.statusBarBackground, b.statusBarBackground, t)!,
      statusBarTextColor:
          Color.lerp(a.statusBarTextColor, b.statusBarTextColor, t)!,
      headerBarBackground:
          Color.lerp(a.headerBarBackground, b.headerBarBackground, t)!,
      headerBarTextColor:
          Color.lerp(a.headerBarTextColor, b.headerBarTextColor, t)!,
      scrollbarThumbColor:
          Color.lerp(a.scrollbarThumbColor, b.scrollbarThumbColor, t)!,
      scrollbarTrackColor:
          Color.lerp(a.scrollbarTrackColor, b.scrollbarTrackColor, t)!,
    );
  }
}

/// InheritedWidget to provide FlutterLaneThemeData down the tree.
class FlutterLaneTheme extends InheritedWidget {
  final FlutterLaneThemeData data;

  const FlutterLaneTheme({
    super.key,
    required this.data,
    required super.child,
  });

  static FlutterLaneThemeData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<FlutterLaneTheme>();
    assert(inherited != null, 'No FlutterLaneTheme found in context');
    return inherited!.data;
  }

  @override
  bool updateShouldNotify(FlutterLaneTheme oldWidget) => data != oldWidget.data;
}
