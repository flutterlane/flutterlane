import 'package:flutter/material.dart';

/// A single item in the Chrome-style hamburger menu.
///
/// Create regular items with [FlutterLaneMenuItem] and dividers
/// with [FlutterLaneMenuItem.divider].
///
/// Example:
/// ```dart
/// FlutterLaneMenuItem(
///   label: 'Save',
///   icon: Icons.save_outlined,
///   shortcut: 'Ctrl+S',
///   onTap: () => saveFile(),
/// )
/// ```
class FlutterLaneMenuItem {
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? shortcut;
  final bool isDivider;

  const FlutterLaneMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.shortcut,
  }) : isDivider = false;

  const FlutterLaneMenuItem.divider()
      : label = null,
        icon = null,
        onTap = null,
        shortcut = null,
        isDivider = true;
}
