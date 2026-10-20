import 'package:centrally/features/students/preview/figma_students_preview.dart';
import 'package:centrally/features/students/preview/student_preview_data.dart';
import 'package:centrally/features/students/preview/student_filter_sheet.dart';
import 'package:centrally/features/students/presentation/design/student_filter_chip.dart';
import 'package:centrally/features/students/presentation/design/student_directory_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/load_test_fonts.dart';
import 'package:centrally/core/widgets/app_search_empty.dart';
import 'helpers/pump_session_design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  testWidgets(
    'student filters combine, reset and cancel without changing applied results',
    (tester) async {
      await pumpSessionDesign(
        tester,
        () => Scaffold(
          body: FigmaStudentsPreview(students: StudentPreviewData.fixtures()),
        ),
      );
      Future<void> chip(String key) async {
        await tester.tap(
          find.widgetWithText(StudentFilterChip, 'student_design_$key'.tr()),
        );
        await tester.pumpAndSettle();
      }

      Future<void> apply() async {
        await tester.tap(find.text('student_design_show_results'.tr()));
        await tester.pumpAndSettle();
      }

      await chip('payment');
      await chip('paid');
      await apply();
      expect(
        tester
            .widgetList<StudentDirectoryRow>(find.byType(StudentDirectoryRow))
            .every((w) => w.data.paid),
        isTrue,
      );
      await chip('level');
      await chip('weak');
      await apply();
      expect(find.text('student_design_no_results'.tr()), findsOneWidget);
      expect(
        find.image(const AssetImage(AppSearchEmpty.imagePath)),
        findsOneWidget,
      );
      await chip('all');
      expect(find.byType(StudentDirectoryRow), findsNWidgets(6));
      await chip('level');
      await chip('excellent');
      Navigator.of(tester.element(find.byType(StudentFilterSheet))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(StudentDirectoryRow), findsNWidgets(6));
      await tester.enterText(find.byType(TextField), 'not found');
      await tester.pumpAndSettle();
      expect(find.text('student_design_no_results'.tr()), findsOneWidget);
      expect(
        find.image(const AssetImage(AppSearchEmpty.imagePath)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
