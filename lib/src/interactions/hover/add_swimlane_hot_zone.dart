import 'package:flutter/material.dart';

import '../../theme/flutter_lane_theme.dart';

/// Right-edge hover hot zone for adding a new swimlane.
///
/// Hidden by default (zero width). On hover, expands and shows "+" icon.
/// Tap triggers the onAdd callback.
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
          width: _isHovered ? 32 : 4,
          color: _isHovered ? theme.hoverZoneActiveColor : Colors.transparent,
          alignment: Alignment.center,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _isHovered ? 1 : 0,
            child: const Icon(Icons.add, size: 16, color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
