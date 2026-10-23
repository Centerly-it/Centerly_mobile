import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/features/academics/presentation/student_academics_page.dart';
import 'package:centrally/features/attendance/presentation/student_attendance_page.dart';
import 'package:centrally/features/finances/presentation/teacher_finance_page.dart';
import 'package:centrally/features/notes/presentation/student_note_page.dart';
import 'package:centrally/features/notifications/presentation/teacher_notifications_page.dart';
import 'package:centrally/features/secretaries/presentation/teacher_secretaries_page.dart';
import 'package:centrally/features/students/presentation/student_profile_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/completion_fixture.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/load_test_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await initializeDateFormatting();
    await loadTestFonts();
  });
  final date = DateTime(2026, 10, 19);
  final pages = <String, Widget>{
    'exams': StudentAcademicsPage(studentId: 'student', initialDate: date),
    'attendance': StudentAttendancePage(
      studentId: 'student',
      initialDate: date,
    ),
    'invoices': TeacherFinancePage(initialDate: date),
    'note': const StudentNotePage(studentId: 'student'),
    'archivedNote': const StudentNotePage(studentId: 'student', readOnly: true),
    'secretaries': const TeacherSecretariesPage(),
    'notifications': const TeacherNotificationsPage(),
    'profile': const StudentProfilePage(
      studentId: '30000000-0000-0000-0000-000000000001',
    ),
  };
  for (final language in ['en', 'ar']) {
    for (final entry in pages.entries) {
      testWidgets(
        '${entry.key} renders SQL contract at 320px/200% in $language',
        (tester) async {
          tester.view.physicalSize = const Size(320, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final fixture = CompletionFixture();
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
                supportedLocales: [Locale(language)],
                startLocale: Locale(language),
                saveLocale: false,
                path: 'assets/translations',
                child: LocalizedTestApp(home: entry.value, scale: 2),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(fixture.requests, isNotEmpty);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.text('error_title'.tr()), findsNothing);
          expect(tester.takeException(), isNull);
          if (entry.key == 'profile') {
            expect(find.text('student_qr_deferred'.tr()), findsNothing);
            expect(find.byIcon(Icons.qr_code_scanner_outlined), findsNothing);
          }
          if (entry.key == 'archivedNote') {
            expect(
              tester.widget<TextField>(find.byType(TextField)).readOnly,
              isTrue,
            );
            expect(find.byType(FilledButton), findsNothing);
          }
          if (entry.key == 'exams' || entry.key == 'invoices') {
            final kind = entry.key == 'exams'
                ? 'completion_assignments'
                : 'completion_payments';
            await tester.ensureVisible(find.text(kind.tr()));
            await tester.tap(find.text(kind.tr()));
            await tester.pumpAndSettle();
            expect(find.text('error_title'.tr()), findsNothing);
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }
}
