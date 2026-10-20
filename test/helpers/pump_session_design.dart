import 'package:centrally/core/localization/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'localized_test_app.dart';
import 'capture_widget.dart';

Future<GlobalKey> pumpSessionDesign(
  WidgetTester tester,
  Widget Function() body, {
  String locale = 'ar',
  double scale = 1,
  double width = 390,
  double height = 909,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final key = GlobalKey();
  await tester.runAsync(() async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        startLocale: Locale(locale),
        saveLocale: false,
        path: 'assets/translations',
        assetLoader: const CodegenLoader(),
        child: RepaintBoundary(
          key: key,
          child: LocalizedTestApp(
            scale: scale,
            home: Builder(builder: (_) => body()),
          ),
        ),
      ),
    );
  });
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    for (final file in ['04ab7.png', '92ea1.png', '9578e.png']) {
      await precacheImage(
        AssetImage('assets/figma/sessions/$file'),
        key.currentContext!,
      );
    }
  });
  await tester.pumpAndSettle();
  return key;
}

Future<void> captureSessionDesign(
  WidgetTester tester,
  GlobalKey key,
  String name,
) async {
  expect(tester.takeException(), isNull);
  if (const bool.fromEnvironment('CAPTURE_SESSION_DESIGN')) {
    await tester.runAsync(
      () => captureWidget(key, 'docs/screenshots/figma-sessions/$name.png'),
    );
  }
}
