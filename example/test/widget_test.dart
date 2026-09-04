// Smoke tests for the FlutterLane example app.
//
// The app persists layouts/themes to disk on startup, which requires the
// desktop path_provider host. `flutter test` runs without a plugin
// registrant, so we substitute a temp-dir path provider and let the real
// file I/O finish on the live event loop (runAsync).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:flutterlane/flutterlane.dart';

import 'package:flutterlane_example/main.dart' as example;

/// Stand-in for the desktop path_provider host used under `flutter test`.
class _TestPathProvider extends PathProviderPlatform {
  String? _dir;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    // Cache one dir so multiple app instances within a test file share the
    // same persistence store (enables restart-style tests).
    return _dir ??= (await Directory.systemTemp.createTemp('flutterlane_example'))
        .path;
  }
}

Future<void> _pumpApp(WidgetTester tester,
    {double width = 1600, double height = 1000}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const example.FlutterLaneExampleApp());

  // The app shows a spinner until its async init (storage + theme) is done.
  // That init does real file I/O, which only completes on the real event
  // loop, so poll from inside runAsync until the splash disappears.
  await tester.runAsync(() async {
    for (var i = 0; i < 200; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      await tester.pump();
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
    }
  });
  expect(tester.takeException(), isNull);
  expect(find.byType(CircularProgressIndicator), findsNothing);
}

/// Taps a window tab by its index inside the WindowTabBar.
///
/// Tab titles are painted on a canvas (TextPainter), so they are not
/// discoverable as Text widgets — tap the geometric center instead.
Future<void> _tapWindowTab(WidgetTester tester, int index) async {
  final barRect = tester.getRect(find.byType(WindowTabBar).first);
  // Width accounting mirroring window_tab_bar.dart (no overflow with
  // 3 tabs): right pad 4 + new-tab button 28 + left pad 8 + gap 5.
  const chrome = 4 + 28 + 8 + 5;
  final tabWidth = (barRect.width - chrome) / 3;
  final center = Offset(
    barRect.left + 8 + tabWidth * (index + 0.5),
    barRect.top + 4 + TabBarStyle.tabHeight / 2,
  );
  await tester.tapAt(center);
  // Let the tab-change handler switch the workspace layout.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
}

void main() {
  setUpAll(() {
    PathProviderPlatform.instance = _TestPathProvider();
  });

  testWidgets('App launches without error', (WidgetTester tester) async {
    await _pumpApp(tester);

    // Verify the app rendered past the splash without errors.
    expect(find.byType(example.FlutterLaneExampleApp), findsOneWidget);
  });

  testWidgets('window tabs switch to each workspace dedicated layout',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    // Default tab (FlutterLane) → full IDE layout: status bar shows the
    // layout name and the Editor pane shows FlutterLane's README.
    expect(find.text('Layout: FlutterLane'), findsOneWidget);

    // Design Docs → docs layout with an Editor + Preview split.
    await _tapWindowTab(tester, 1);
    expect(find.text('Layout: Design Docs'), findsOneWidget);
    // Design Docs splits Editor into an Editor + Preview workspace.
    expect(find.text('Preview'), findsWidgets);
    expect(
        find.textContaining('Documentation for the FlutterLane'), findsWidgets);

    // GitHub → repo layout with Editor + Terminal.
    await _tapWindowTab(tester, 2);
    expect(find.text('Layout: GitHub'), findsOneWidget);
    expect(find.text('Terminal'), findsWidgets);
    expect(find.textContaining('VS Code-style workspaces'), findsWidgets);

    // Back to FlutterLane → full IDE again.
    await _tapWindowTab(tester, 0);
    expect(find.text('Layout: FlutterLane'), findsOneWidget);
    expect(find.text('Copilot'), findsWidgets);
  });

  testWidgets('clicking a markdown file in the Explorer opens it in the Editor',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    // Switch to Design Docs whose explorer tree contains guides/layout.md.
    await _tapWindowTab(tester, 1);
    expect(find.text('Layout: Design Docs'), findsOneWidget);

    // The Editor initially shows the workspace default file (index.md).
    expect(find.textContaining('Swimlanes organize the window'), findsWidgets);

    // Click the layout.md leaf in the Explorer tree.
    final leaf = find.text('layout.md');
    expect(leaf, findsOneWidget);
    await tester.tap(leaf);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // The Editor pane now renders layout.md content.
    expect(find.textContaining('# Layout Guide'), findsWidgets);
    expect(find.textContaining('Swimlanes are horizontal columns.'),
        findsWidgets);
  });
}
