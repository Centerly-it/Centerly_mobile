import 'package:centrally/features/students/preview/figma_students_preview.dart';
import 'package:centrally/features/students/preview/student_profile_preview.dart';
import 'package:centrally/features/students/preview/student_preview_data.dart';
import 'package:centrally/features/students/presentation/design/student_filter_chip.dart';
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
    for (final state in [
      'list',
      'filter',
      'info',
      'attendance',
      'academics',
      'payments',
    ]) {
      testWidgets('student $state $locale at 320px with 200% text', (
        tester,
      ) async {
        await pumpSessionDesign(
          tester,
          () {
            final students = StudentPreviewData.fixtures();
            return state == 'list' || state == 'filter'
                ? Scaffold(body: FigmaStudentsPreview(students: students))
                : StudentProfilePreview(
                    data: students[1],
                    initialTab: [
                      'info',
                      'attendance',
                      'academics',
                      'payments',
                    ].indexOf(state),
                  );
          },
          locale: locale,
          width: 320,
          scale: 2,
        );
        if (state == 'filter') {
          await tester.tap(
            find.widgetWithText(StudentFilterChip, 'student_design_level'.tr()),
          );
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
