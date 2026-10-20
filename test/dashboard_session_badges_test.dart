import 'package:centrally/core/preview/preview_sessions.dart';
import 'package:centrally/features/dashboard/presentation/dashboard_session_schedule.dart';
import 'package:centrally/features/sessions/domain/session_record.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/pump_session_design.dart';
import 'helpers/load_test_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final locale in ['ar', 'en']) {
    testWidgets('dashboard schedule shows three lifecycle badges in $locale', (
      tester,
    ) async {
      await pumpSessionDesign(
        tester,
        () => Scaffold(
          body: SingleChildScrollView(
            child: DashboardSessionSchedule(
              sessions: PreviewSessions()
                  .list('2026-10-20')
                  .map(SessionRecord.fromJson)
                  .toList(),
            ),
          ),
        ),
        locale: locale,
        width: 320,
        scale: 2,
      );
      for (final status in ['completed', 'ongoing', 'upcoming']) {
        expect(find.text('status_$status'.tr()), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
