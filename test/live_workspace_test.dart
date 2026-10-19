import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/di/di.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/load_test_fonts.dart';
import 'package:centrally/features/dashboard/data/dashboard_repository.dart';
import 'package:centrally/screens/teacher/teacher_workspace.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/dashboard_read_fixture.dart';
import 'helpers/capture_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final locale in ['ar', 'en']) {
    for (final width in [320.0, 430.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'live workspace $locale at $width and ${(scale * 100).toInt()}% text',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final fixture = DashboardReadFixture();
            final boundary = GlobalKey();
            final client = (await tester.runAsync(
              () async => fixture.client(),
            ))!;
            getIt.registerSingleton<DashboardRepository>(
              DashboardRepository(TeacherReadClient(client)),
            );
            addTearDown(() async {
              await tester.runAsync(() async {
                await getIt.reset();
                await client.dispose();
              });
            });
            await tester.runAsync(() async {
              await tester.pumpWidget(
                EasyLocalization(
                  supportedLocales: const [Locale('ar'), Locale('en')],
                  startLocale: Locale(locale),
                  saveLocale: false,
                  path: 'assets/translations',
                  child: LocalizedTestApp(
                    home: RepaintBoundary(
                      key: boundary,
                      child: const TeacherWorkspace(),
                    ),
                    scale: scale,
                  ),
                ),
              );
            });
            await tester.pumpAndSettle();
            expect(find.text('12'), findsOneWidget);
            expect(tester.takeException(), isNull);
            if (const bool.fromEnvironment('CAPTURE_LIVE')) {
              await tester.runAsync(
                () => captureWidget(
                  boundary,
                  'docs/screenshots/live-shell/$locale-${width.toInt()}-scale${scale.toInt()}.png',
                ),
              );
            }
            final semantics = tester.ensureSemantics();

            expect(find.byTooltip('auth_logout'.tr()), findsOneWidget);
            await tester.tap(
              find.byIcon(Icons.account_balance_wallet_outlined),
            );
            await tester.pumpAndSettle();
            expect(find.text('workspace_pending'.tr()), findsOneWidget);
            fixture.fail = true;
            await tester.tap(find.byIcon(Icons.home_outlined));
            await tester.pumpAndSettle();
            expect(find.text('error_title'.tr()), findsOneWidget);
            expect(tester.takeException(), isNull);
            fixture.fail = false;
            await tester.ensureVisible(find.byIcon(Icons.refresh));
            await tester.tap(find.byIcon(Icons.refresh));
            await tester.pumpAndSettle();
            expect(find.text('12'), findsOneWidget);
            expect(fixture.calls, 3);
            semantics.dispose();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
