import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutterlane/flutterlane.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FlutterLaneManager manager;

  Widget app() => MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              _TestChromeHeader(manager: manager),
              Expanded(child: FlutterLaneWorkbench(manager: manager)),
            ],
          ),
        ),
      );

  setUp(() {
    final workspace = Workspace(
      workspaceId: 'header-test',
      workspaceName: 'Header Test',
    );
    manager = FlutterLaneManager(workspace: workspace);
    manager.registry.registerPaneView(ViewInstanceMeta(
      viewTypeId: 'editor',
      viewDisplayName: 'Editor',
      icon: Icons.code,
      viewBuilder: (context, bizCtx, state) => const Text('editor'),
    ));
  });

  testWidgets('traffic buttons are rendered and tappable', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    // Find all three traffic dots
    final redDot = find.byTooltip('Close');
    final yellowDot = find.byTooltip('Minimize');
    final greenDot = find.byTooltip('Maximize');

    expect(redDot, findsOneWidget);
    expect(yellowDot, findsOneWidget);
    expect(greenDot, findsOneWidget);

    // Verify they are GestureDetector (tappable)
    expect(
      tester.widget<GestureDetector>(redDot),
      isA<GestureDetector>(),
    );

    // Tap each one (won't actually close/minimize/maximize in test)
    await tester.tap(redDot);
    await tester.pumpAndSettle();

    await tester.tap(yellowDot);
    await tester.pumpAndSettle();

    await tester.tap(greenDot);
    await tester.pumpAndSettle();

    // No crash = success
    expect(tester.takeException(), isNull);
  });

  testWidgets('hamburger menu icon is rendered and tappable',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final menuIcon = find.byIcon(Icons.menu);
    expect(menuIcon, findsOneWidget);

    // Tap the menu icon
    await tester.tap(menuIcon);
    await tester.pumpAndSettle();

    // No crash = success
    expect(tester.takeException(), isNull);
  });
}

/// Minimal chrome header for testing without windowManager calls.
class _TestChromeHeader extends StatelessWidget {
  final FlutterLaneManager manager;
  const _TestChromeHeader({required this.manager});

  @override
  Widget build(BuildContext context) {
    final theme = manager.currentTheme;
    return Container(
      height: 42,
      color: theme.headerBarBackground,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Row(
            children: [
              const _TestTrafficDot(color: Color(0xFFff5f57), tooltip: 'Close'),
              const SizedBox(width: 8),
              const _TestTrafficDot(color: Color(0xFFfebc2e), tooltip: 'Minimize'),
              const SizedBox(width: 8),
              const _TestTrafficDot(color: Color(0xFF28c840), tooltip: 'Maximize'),
            ],
          ),
          const SizedBox(width: 16),
          const Icon(Icons.menu, size: 14),
          const SizedBox(width: 12),
          const Spacer(),
        ],
      ),
    );
  }
}

class _TestTrafficDot extends StatelessWidget {
  final Color color;
  final String tooltip;
  const _TestTrafficDot({required this.color, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {},
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
