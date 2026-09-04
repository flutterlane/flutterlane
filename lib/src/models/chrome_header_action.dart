import 'package:flutter/material.dart';

/// A clickable action button in the Chrome header bar.
///
/// These appear on the right side of the header, after the window tabs.
/// The built-in actions (save layout, cycle theme, reset layout) are
/// always present; use [FlutterLaneHeaderAction] to add custom ones.
///
/// Example:
/// ```dart
/// FlutterLaneHeaderAction(
///   icon: Icons.play_arrow,
///   tooltip: 'Run',
///   onTap: () => runProject(),
/// )
/// ```
class FlutterLaneHeaderAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const FlutterLaneHeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
}
