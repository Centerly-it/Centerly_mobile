import 'package:centrally/features/students/preview/student_preview_data.dart';
import 'package:centrally/features/students/preview/student_profile_preview.dart';
import 'package:centrally/features/students/presentation/design/student_profile_tabs.dart';
import 'package:centrally/features/students/presentation/design/student_attendance_design.dart';
import 'package:centrally/features/students/presentation/design/student_academics_design.dart';
import 'package:centrally/features/students/presentation/design/student_payments_design.dart';
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
  testWidgets(
    'student note validates, saves only to selected student and survives profile tabs',
    (tester) async {
      final students = StudentPreviewData.fixtures();
      await pumpSessionDesign(
        tester,
        () => StudentProfilePreview(data: students[1]),
      );
      await tester.ensureVisible(find.text('student_design_edit_note'.tr()));
      await tester.tap(find.text('student_design_edit_note'.tr()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '  ');
      await tester.tap(find.text('student_design_save'.tr()));
      await tester.pumpAndSettle();
      expect(find.text('student_design_note_required'.tr()), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '  updated note  ');
      await tester.tap(find.text('student_design_save'.tr()));
      await tester.pumpAndSettle();
      expect(students[1].editedNote, 'updated note');
      expect(students.first.editedNote, isNull);
      for (final entry in {
        'attendance': StudentAttendanceDesign,
        'academics': StudentAcademicsDesign,
        'payments': StudentPaymentsDesign,
      }.entries) {
        final tab = find.descendant(
          of: find.byType(StudentProfileTabs),
          matching: find.text('student_design_${entry.key}'.tr()),
        );
        await tester.ensureVisible(tab);
        await tester.tap(tab);
        await tester.pumpAndSettle();
        expect(find.byType(entry.value), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
