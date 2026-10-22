import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/di/di.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/load_test_fonts.dart';
import 'package:centrally/features/dashboard/data/dashboard_repository.dart';
import 'package:centrally/features/sessions/data/session_repository.dart';
import 'package:centrally/features/sessions/presentation/live_sessions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/session_read_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
    await initializeDateFormatting();
  });
  testWidgets('server date, Cairo time, bounded week/month and empty state', (
    tester,
  ) async {
    final fixture = SessionReadFixture();
    final client = (await tester.runAsync(() async => fixture.client()))!;
    final api = TeacherReadClient(client);
    getIt.registerSingleton<DashboardRepository>(DashboardRepository(api));
    getIt.registerSingleton<SessionRepository>(SessionRepository(api));
    addTearDown(
      () => tester.runAsync(() async {
        await getIt.reset();
        await client.dispose();
      }),
    );
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en')],
          startLocale: const Locale('en'),
          saveLocale: false,
          path: 'assets/translations',
          child: const LocalizedTestApp(home: Scaffold(body: LiveSessions())),
        ),
      );
    });
    await tester.pumpAndSettle();
    expect(find.textContaining('12:00'), findsOneWidget);
    expect(find.textContaining('Group A', findRichText: true), findsOneWidget);
    expect(fixture.ranges.first['p_from'], '2026-07-01');
    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(fixture.ranges.last['p_from'], '2026-06-28');
    expect(fixture.ranges.last['p_to'], '2026-07-04');
    expect(find.text('No Sessions'), findsOneWidget);
    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    expect(fixture.ranges.last['p_to'], '2026-07-31');
    expect(tester.takeException(), isNull);
  });
}
