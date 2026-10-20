import 'package:centrally/features/dashboard/preview/preview_unpaid_students.dart';
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
    for (final scale in [1.0, 2.0]) {
      testWidgets('unpaid summary $locale scale $scale opens preview list', (
        tester,
      ) async {
        final key = await pumpSessionDesign(
          tester,
          () => Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: PreviewUnpaidStudents(now: DateTime.utc(2026, 10, 20, 18)),
            ),
          ),
          locale: locale,
          scale: scale,
          width: scale == 1 ? 390 : 320,
        );
        expect(find.text('5'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (locale == 'ar' && scale == 1) {
          await captureSessionDesign(tester, key, 'home-unpaid');
        }
        await tester.tap(find.text('home_unpaid_view'.tr()));
        await tester.pumpAndSettle();
        expect(find.text('finance_demo_student_2'.tr()), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
