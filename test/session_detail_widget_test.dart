import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/features/sessions/presentation/session_detail_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/session_detail_fixture.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/load_test_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
    await initializeDateFormatting();
  });
  for (final lang in ['en', 'ar']) {
    testWidgets('read-only cancelled detail at 2x: $lang', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = SessionDetailFixture()..cancelled = true;
      final client = (await tester.runAsync(() async => fixture.client()))!;
      getIt.registerSingleton<TeacherReadClient>(TeacherReadClient(client));
      addTearDown(
        () => tester.runAsync(() async {
          await getIt.reset();
          await client.dispose();
        }),
      );
      await tester.runAsync(
        () async => tester.pumpWidget(
          EasyLocalization(
            supportedLocales: [Locale(lang)],
            startLocale: Locale(lang),
            saveLocale: false,
            path: 'assets/translations',
            child: const LocalizedTestApp(
              scale: 2,
              home: SessionDetailPage(sessionId: 'session-a'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      await tester.scrollUntilVisible(find.text('Retained history'), 300);
      expect(find.text('Retained history'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Student A'), 300);
      expect(find.text('Student A'), findsOneWidget);
      fixture.corrected = true;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.textContaining('Secretary A'), 300);
      expect(find.text('Student A'), findsOneWidget);
      expect(find.textContaining('Secretary A'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
