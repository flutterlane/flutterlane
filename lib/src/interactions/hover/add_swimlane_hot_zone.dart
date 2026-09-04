import 'package:flutter/material.dart';

import '../../theme/flutter_lane_theme.dart';

/// Bottom-right corner hover zone for adding a new swimlane.
///
/// 64×64 corner area. Hidden by default (6px dot). On hover, expands and
/// shows "+" icon. Does not overlap with the resize handle above it.
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
          width: _isHovered ? 32 : 6,
          height: _isHovered ? 32 : 6,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.hoverZoneActiveColor
                : theme.hoverZoneColor,
            borderRadius: BorderRadius.circular(_isHovered ? 16 : 3),
          ),
          alignment: Alignment.center,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _isHovered ? 1 : 0,
            child: const Icon(Icons.add, size: 14, color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
