import 'dart:io';
import 'dart:ui' as ui;
import 'package:centrally/core/theme/theme_manager.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/main_shell_view.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    final loader = FontLoader('Cairo');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/fonts/Cairo-$weight.ttf'));
    }
    await loader.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets('approved teacher shell preserves Arabic visuals', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        startLocale: const Locale('ar'),
        saveLocale: false,
        child: _VisualApp(boundaryKey: key),
      ),
    );
    await tester.pumpAndSettle();
    for (final entry in {
      'home': null,
      'groups': Icons.groups_2_outlined,
      'sessions': Icons.calendar_month_outlined,
    }.entries) {
      if (entry.value != null) {
        await tester.tap(find.byIcon(entry.value!));
        await tester.pumpAndSettle();
      }
      if (const bool.fromEnvironment('CAPTURE_VISUALS')) {
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!;
          final file = File('docs/screenshots/e1312a2/${entry.key}-ar-390.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes.buffer.asUint8List());
          image.dispose();
        });
      }
      expect(Directionality.of(key.currentContext!), TextDirection.rtl);
      expect(tester.takeException(), isNull);
    }
  });
}

class _VisualApp extends StatelessWidget {
  const _VisualApp({required this.boundaryKey});
  final GlobalKey boundaryKey;
  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: context.locale,
    theme: AppTheme.light,
    supportedLocales: context.supportedLocales,
    localizationsDelegates: context.localizationDelegates,
    home: RepaintBoundary(
      key: boundaryKey,
      child: const MainShellView(role: UserRole.teacher),
    ),
  );
}
