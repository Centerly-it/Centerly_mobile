import 'package:centrally/app/bootstrap_preview.dart';
import 'package:centrally/core/localization/codegen_loader.g.dart';
import 'package:centrally/core/config/app_config.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/screens/teacher/teacher_workspace.dart';
import 'package:centrally/features/notifications/presentation/teacher_notifications_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/load_test_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final locale in ['ar', 'en']) {
    testWidgets('offline preview main tabs render in $locale', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      getIt.registerSingleton<AppConfig>(
        const AppConfig(url: '', publishableKey: ''),
      );
      await tester.runAsync(bootstrapPreview);
      addTearDown(() => getIt.reset());
      await tester.runAsync(() async {
        await tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale('ar'), Locale('en')],
            startLocale: Locale(locale),
            saveLocale: false,
            path: 'assets/translations',
            assetLoader: const CodegenLoader(),
            child: const LocalizedTestApp(home: TeacherWorkspace()),
          ),
        );
      });
      await tester.pumpAndSettle();
      expect(find.text('72'), findsOneWidget);
      expect(tester.takeException(), isNull);
      for (final icon in [
        Icons.calendar_month_outlined,
        Icons.groups_2_outlined,
        Icons.account_balance_wallet_outlined,
      ]) {
        await tester.tap(find.byIcon(icon).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('error_title'.tr()), findsNothing);
        for (final text in tester.widgetList<Text>(find.byType(Text))) {
          expect(text.data?.startsWith('dashboard_') ?? false, isFalse);
        }
      }
      await tester.tap(find.byTooltip('completion_notifications'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(TeacherNotificationsPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
