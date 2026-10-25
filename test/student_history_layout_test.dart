import 'package:centrally/features/students/domain/student_membership.dart';
import 'package:centrally/features/students/presentation/student_membership_card.dart';
import 'package:centrally/features/attendance/domain/student_attendance_record.dart';
import 'package:centrally/features/attendance/presentation/live_attendance_table.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/localized_test_app.dart';
import 'helpers/load_test_fonts.dart';
import 'helpers/capture_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await loadTestFonts();
  });
  for (final c in [
    ('ar', 320.0, 2.0),
    ('en', 320.0, 2.0),
    ('ar', 390.0, 1.0),
  ]) {
    final locale = c.$1;
    testWidgets(
      'organized membership and attendance $locale at narrow large text',
      (tester) async {
        tester.view.physicalSize = Size(c.$2, 1200);
        final boundary = GlobalKey();
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final member = StudentMembership(
          id: 'm',
          groupId: 'g',
          groupName: 'مجموعة فيزياء ثالثة ثانوي',
          subject: 'فيزياء',
          grade: 'عام',
          status: 'inactive',
          joinedAt: DateTime.utc(2026, 10, 1),
          leftAt: DateTime.utc(2026, 10, 20),
        );
        final row = StudentAttendanceRecord(
          id: 'a',
          sessionId: 's',
          status: 'excused',
          date: '2026-10-20',
          sessionStatus: 'cancelled',
          updatedAt: DateTime.utc(2026, 10, 20),
          group: 'مجموعة فيزياء ثالثة ثانوي',
          actor: 'اسم السكرتير',
        );
        final content = RepaintBoundary(
          key: boundary,
          child: Scaffold(
            body: ListView(
              children: [
                StudentMembershipCard(row: member),
                LiveAttendanceTable(rows: [row]),
              ],
            ),
          ),
        );
        final app = EasyLocalization(
          supportedLocales: const [Locale('ar'), Locale('en')],
          startLocale: Locale(locale),
          saveLocale: false,
          path: 'assets/translations',
          child: LocalizedTestApp(scale: c.$3, home: content),
        );
        await tester.runAsync(() async => tester.pumpWidget(app));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (c.$3 == 1) {
          await tester.runAsync(
            () => captureWidget(
              boundary,
              'build/ui-review/student-history-ar.png',
            ),
          );
        }
        expect(find.text('عام'), findsNothing);
        expect(find.text('membership_left_on'.tr()), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -700));
        await tester.pumpAndSettle();
        expect(find.text('اسم السكرتير'), findsOneWidget);
        expect(find.text('detail_cancel_history'.tr()), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
