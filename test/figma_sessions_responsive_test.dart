import 'package:centrally/features/sessions/preview/figma_sessions_preview.dart';
import 'package:centrally/features/sessions/preview/session_design_detail.dart';
import 'package:centrally/features/sessions/preview/session_design_fixture.dart';
import 'package:centrally/features/sessions/preview/session_attendance_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/pump_session_design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final locale in ['ar', 'en']) {
    for (final page in ['month', 'detail', 'attendance']) {
      testWidgets('Figma $page $locale 320px 200%', (tester) async {
        await pumpSessionDesign(
          tester,
          () {
            final date = DateTime(2026, 10, 20);
            final data = SessionDesignFixture().day(date).first;
            return page == 'month'
                ? Scaffold(body: FigmaSessionsPreview(initialDate: date))
                : page == 'detail'
                ? SessionDesignDetail(data: data)
                : SessionAttendancePreview(data: data);
          },
          locale: locale,
          width: 320,
          scale: 2,
        );
        if (page == 'month') {
          await tester.tap(find.text('sessions_month'.tr()));
          await tester.pumpAndSettle();
        }
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
