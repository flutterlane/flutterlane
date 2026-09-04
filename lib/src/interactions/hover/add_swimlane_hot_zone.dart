import 'package:flutter/material.dart';

import '../../theme/flutter_lane_theme.dart';

/// Bottom-right edge hover zone for adding a new swimlane.
///
/// A thin 16px-wide strip along the right edge, half the swimlane height.
/// Invisible by default. On hover, reveals a "+" icon. Tapping adds a new swimlane.
class AddSwimlaneHotZone extends StatefulWidget {
  final VoidCallback onAdd;

  const AddSwimlaneHotZone({super.key, required this.onAdd});

  @override
  State<AddSwimlaneHotZone> createState() => _AddSwimlaneHotZoneState();
}

class _AddSwimlaneHotZoneState extends State<AddSwimlaneHotZone> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onAdd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.hoverZoneActiveColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(_isHovered ? 4 : 0),
          ),
          alignment: Alignment.center,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _isHovered ? 1 : 0,
            child: Icon(
              Icons.add,
              size: 12,
              color: theme.hoverZoneActiveColor,
            ),
          ),
        ),
      ),
    );
  }
}
