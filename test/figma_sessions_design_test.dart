import 'package:centrally/features/sessions/preview/figma_sessions_preview.dart';
import 'package:centrally/features/sessions/preview/session_design_detail.dart';
import 'package:centrally/features/sessions/preview/session_design_fixture.dart';
import 'package:centrally/features/sessions/preview/session_attendance_preview.dart';
import 'package:centrally/features/sessions/presentation/design/session_design_card.dart';
import 'package:centrally/features/sessions/presentation/design/session_student_row.dart';
import 'package:centrally/features/sessions/presentation/design/session_summary_strip.dart';
import 'package:centrally/features/sessions/presentation/design/session_calendar_day.dart';
import 'package:centrally/features/sessions/presentation/design/session_calendar_dot.dart';
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
  final date = DateTime(2026, 10, 20);
  for (final period in ['day', 'week', 'month', 'empty']) {
    testWidgets('Figma sessions $period', (tester) async {
      final key = await pumpSessionDesign(
        tester,
        () => Scaffold(body: FigmaSessionsPreview(initialDate: date)),
      );
      if (period != 'day') {
        await tester.tap(
          find.text('sessions_${period == 'empty' ? 'month' : period}'.tr()),
        );
        await tester.pumpAndSettle();
      }
      if (period == 'empty') {
        await tester.tap(find.byKey(const ValueKey('calendar-2026-10-23')));
        await tester.pumpAndSettle();
        expect(find.byType(SessionDesignCard), findsNothing);
      } else {
        expect(find.byType(SessionDesignCard), findsWidgets);
      }
      if (period == 'month' || period == 'empty') {
        final days = tester
            .widgetList<SessionCalendarDay>(find.byType(SessionCalendarDay))
            .toList();
        final dates = days
            .map((cell) => '${cell.day.year}-${cell.day.month}-${cell.day.day}')
            .toSet();
        expect(dates.length, days.length);
        expect(
          days
              .where((cell) => cell.day.month == 10 && cell.day.day == 29)
              .length,
          1,
        );
        final cancelledDay = days.singleWhere(
          (cell) => cell.day.month == 10 && cell.day.day == 28,
        );
        expect(cancelledDay.hasCancelledSessions, isTrue);
        expect(cancelledDay.hasSessions, isTrue);
        expect(
          find.descendant(
            of: find.byWidget(cancelledDay),
            matching: find.byType(SessionCalendarDot),
          ),
          findsNWidgets(2),
        );
      }
      expect(find.byType(SessionSummaryStrip), findsNothing);
      expect(
        find.text('design_cancelled'.tr()),
        period == 'month' || period == 'empty' ? findsOneWidget : findsNothing,
      );
      for (final element in find.byType(SessionDesignCard).evaluate()) {
        final card = element.widget as SessionDesignCard;
        expect(card.data.cancellationReason, isNull);
        expect(
          find.descendant(
            of: find.byWidget(card),
            matching: find.text('${card.data.present}/${card.data.expected}'),
          ),
          (card.data.current || card.data.completed)
              ? findsOneWidget
              : findsNothing,
        );
      }
      await captureSessionDesign(tester, key, period);
    });
  }
  for (final page in [
    'detail',
    'cancel',
    'all',
    'present',
    'absent',
    'search-empty',
  ]) {
    testWidgets('Figma session $page', (tester) async {
      final key = await pumpSessionDesign(tester, () {
        final data = SessionDesignFixture().day(date).first;
        return page == 'detail' || page == 'cancel'
            ? SessionDesignDetail(data: data)
            : SessionAttendancePreview(data: data);
      }, height: page == 'all' || page == 'present' ? 1109 : 909);
      if (page == 'cancel') {
        await tester.scrollUntilVisible(
          find.text('session_cancel_button'.tr()),
          250,
        );
        await tester.tap(find.text('session_cancel_button'.tr()));
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget);
      }
      if (page == 'present' || page == 'absent') {
        final status = page == 'present' ? 'present' : 'absent';
        final count = page == 'present' ? 19 : 4;
        await tester.tap(
          find.widgetWithText(
            ChoiceChip,
            '${'attendance_$status'.tr()} $count',
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widgetList<SessionStudentRow>(find.byType(SessionStudentRow))
              .every((w) => w.student.status == status),
          isTrue,
        );
      }
      if (page == 'search-empty') {
        await tester.enterText(find.byType(TextField), 'no matching student');
        await tester.pumpAndSettle();
        expect(find.text('design_student_not_found'.tr()), findsOneWidget);
        await tester.drag(find.byType(ListView).first, const Offset(0, 500));
        await tester.pumpAndSettle();
      }
      await captureSessionDesign(tester, key, page);
    });
  }
}
