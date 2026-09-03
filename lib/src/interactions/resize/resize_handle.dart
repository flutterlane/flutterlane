import 'package:flutter/material.dart';

import '../../theme/flutter_lane_theme.dart';

/// A generic resize handle splitter.
///
/// Can be oriented horizontally (for swimlane width resize) or vertically
/// (for section height resize).
class ResizeHandle extends StatefulWidget {
  /// Called with the drag delta in logical pixels.
  final void Function(double delta) onDrag;

  /// Whether this handle is horizontal (left-right) or vertical (up-down).
  final bool isHorizontal;

  /// Whether resize is disabled (e.g. when section is collapsed).
  final bool disabled;

  const ResizeHandle({
    super.key,
    required this.onDrag,
    this.isHorizontal = false,
    this.disabled = false,
  });

  @override
  State<ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<ResizeHandle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);
    final color =
        _isHovered ? theme.resizeHandleHoverColor : theme.resizeHandleColor;

    final size = widget.isHorizontal ? 4.0 : 4.0;
    final hitArea = widget.isHorizontal
        ? const BoxConstraints(minHeight: 8)
        : const BoxConstraints(minWidth: 8);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isHorizontal
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        onPanUpdate: widget.disabled
            ? null
            : (details) {
                final delta =
                    widget.isHorizontal ? details.delta.dx : details.delta.dy;
                widget.onDrag(delta);
              },
        child: ConstrainedBox(
          constraints: hitArea,
          child: Container(
            width: widget.isHorizontal ? size : double.infinity,
            height: widget.isHorizontal ? double.infinity : size,
            color: widget.disabled ? Colors.transparent : color,
          ),
        ),
      ),
    );
  }
}
