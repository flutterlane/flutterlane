import 'package:flutter/material.dart';

import '../../models/pane.dart';
import '../../models/view_instance.dart';
import '../../registry/flutter_lane_registry.dart';
import '../../theme/flutter_lane_theme.dart';

/// Wraps a single Pane's business view content.
///
/// Renders the registered viewBuilder from the registry, passing business
/// context and view state. Falls back to a placeholder if the view type
/// is not registered.
class PaneWidget extends StatelessWidget {
  final Pane pane;
  final FlutterLaneRegistry registry;

  const PaneWidget({
    super.key,
    required this.pane,
    required this.registry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterLaneTheme.of(context);
    final meta = registry.getPaneView(pane.viewInstance.viewTypeId);

    if (meta == null) {
      return _Placeholder(pane.viewInstance, theme);
    }

    return meta.viewBuilder(
      context,
      pane.viewInstance.businessContext,
      pane.viewInstance.viewState,
    );
  }
}

class _Placeholder extends StatelessWidget {
  final ViewInstance instance;
  final FlutterLaneThemeData theme;

  const _Placeholder(this.instance, this.theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.paneContentBackground,
      alignment: Alignment.center,
      child: Text(
        'View: ${instance.viewTypeId}',
        style: TextStyle(color: theme.sectionHeaderTextColor),
      ),
    );
  }
}
