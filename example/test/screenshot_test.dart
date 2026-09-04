// In-process screenshot test for the example app.
//
// Renders each window tab's dedicated workspace layout to a PNG using
// Flutter's golden machinery — no OS-level input is involved, taps are
// injected through the test binding. Run with:
//
//   flutter test test/screenshot_test.dart --update-goldens
//
// to (re)generate the images under test/goldens/.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:flutterlane/flutterlane.dart';

import 'package:flutterlane_example/main.dart' as example;

/// Stand-in for the desktop path_provider host used under `flutter test`.
class _TestPathProvider extends PathProviderPlatform {
  String? _dir;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return _dir ??= (await Directory.systemTemp.createTemp('flutterlane_shot'))
        .path;
  }
}

/// Loads the real Roboto font so golden screenshots show actual text
/// instead of the Ahem placeholder blocks.
Future<void> _loadRoboto() async {
  const candidates = [
    'bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
    'bin/cache/artifacts/material_fonts/Roboto-Medium.ttf',
  ];
  final root =
      Platform.environment['FLUTTER_ROOT']?.isNotEmpty == true
          ? Platform.environment['FLUTTER_ROOT']!
          : '/opt/flutter';
  for (final rel in candidates) {
    final file = File('$root/$rel');
    if (!file.existsSync()) continue;
    final bytes = await file.readAsBytes();
    final loader = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
    return;
  }
  throw StateError('Roboto font not found under $root/bin/cache');
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
  // Let any last init-frame animations finish before capturing.
  await tester.pump(const Duration(milliseconds: 200));
}

/// Taps a window tab by index inside the WindowTabBar (titles are painted
/// on a canvas, so tap the geometric center).
Future<void> _tapWindowTab(WidgetTester tester, int index) async {
  final barRect = tester.getRect(find.byType(WindowTabBar).first);
  // Width accounting mirroring window_tab_bar.dart (3 tabs, no overflow).
  const chrome = 4 + 28 + 8 + 5;
  final tabWidth = (barRect.width - chrome) / 3;
  final center = Offset(
    barRect.left + 8 + tabWidth * (index + 0.5),
    barRect.top + 4 + TabBarStyle.tabHeight / 2,
  );
  await tester.tapAt(center);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 80));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump();
}

void main() {
  setUpAll(() {
    PathProviderPlatform.instance = _TestPathProvider();
  });

  testWidgets('renders each window tab workspace layout to a golden PNG',
      (WidgetTester tester) async {
    // Font file I/O needs the real event loop.
    await tester.runAsync(_loadRoboto);
    await _pumpApp(tester);

    const tabs = [
      (0, 'flutterlane'),
      (1, 'designdocs'),
      (2, 'github'),
    ];
    for (final (index, name) in tabs) {
      await _tapWindowTab(tester, index);
      // Make sure the tab switch actually applied its workspace layout.
      final expected = switch (index) {
        0 => 'Layout: FlutterLane',
        1 => 'Layout: Design Docs',
        _ => 'Layout: GitHub',
      };
      expect(find.text(expected), findsOneWidget,
          reason: 'tab $index should show $expected');

      await expectLater(
        find.byType(example.FlutterLaneExampleApp),
        matchesGoldenFile('goldens/workspace_$name.png'),
      );
    }
  });
}