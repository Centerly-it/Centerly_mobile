import 'package:centrally/features/students/preview/figma_students_preview.dart';
import 'package:centrally/features/students/preview/student_preview_data.dart';
import 'package:centrally/features/students/preview/student_profile_preview.dart';
import 'package:centrally/features/students/presentation/design/student_filter_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/pump_session_design.dart';
import 'helpers/capture_widget.dart';
import 'helpers/verify_design_assets.dart';

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
      testWidgets('students $state $locale Figma render', (tester) async {
        final key = await pumpSessionDesign(
          tester,
          () {
            final data = StudentPreviewData.fixtures();
            return state == 'list' || state == 'filter'
                ? Scaffold(body: FigmaStudentsPreview(students: data))
                : StudentProfilePreview(
                    data: data[1],
                    initialTab: [
                      'info',
                      'attendance',
                      'academics',
                      'payments',
                    ].indexOf(state),
                  );
          },
          locale: locale,
          height: 844,
        );
        if (state == 'filter') {
          await tester.tap(
            find.widgetWithText(StudentFilterChip, 'student_design_level'.tr()),
          );
          await tester.pumpAndSettle();
          for (final level in ['excellent', 'average']) {
            await tester.tap(
              find.widgetWithText(
                StudentFilterChip,
                'student_design_$level'.tr(),
              ),
            );
            await tester.pumpAndSettle();
          }
        }
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/figma/students/d6b26.png'),
            key.currentContext!,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        verifyDesignAssets(tester, 'docs/FIGMA_STUDENT_ASSETS.json');
        if (const bool.fromEnvironment('CAPTURE_STUDENT_DESIGN')) {
          await tester.runAsync(
            () => captureWidget(
              key,
              'docs/screenshots/figma-students/$state-$locale.png',
            ),
          );
        }
      });
    }
  }
}
