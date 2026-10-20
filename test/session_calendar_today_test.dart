import 'package:centrally/features/sessions/preview/session_design_fixture.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:centrally/core/format/cairo_time.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/features/sessions/presentation/design/session_calendar.dart';
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
  testWidgets('preview range never repeats a date across Cairo DST rollback', (
    tester,
  ) async {
    await pumpSessionDesign(tester, () => const Scaffold());
    CairoTime.local(DateTime.utc(2026));
    final zone = tz.getLocation('Africa/Cairo');
    final sessions = SessionDesignFixture().range(
      tz.TZDateTime(zone, 2026, 10, 29),
      tz.TZDateTime(zone, 2026, 10, 31),
    );
    expect(sessions.length, 10);
    expect(sessions.map((s) => s.id).toSet().length, 10);
    expect(sessions.map((s) => CairoTime.date(s.date)).toSet(), {
      '2026-10-29',
      '2026-10-31',
    });
  });
  testWidgets(
    'calendar markers do not allocate attendance rosters for invisible days',
    (tester) async {
      await pumpSessionDesign(tester, () => const Scaffold());
      final fixture = SessionDesignFixture();
      for (var day = 1; day <= 31; day++) {
        fixture.hasSessions(DateTime(2026, 10, day));
        fixture.hasCancelledSessions(DateTime(2026, 10, day));
      }
      expect(fixture.cachedDayCount, 0);
      final sessions = fixture.day(DateTime(2026, 10, 20));
      for (final s in sessions) {
        s.cancellationReason = 'Preview cancellation';
      }
      expect(fixture.hasSessions(DateTime(2026, 10, 20)), false);
      expect(fixture.hasCancelledSessions(DateTime(2026, 10, 20)), true);
      expect(fixture.cachedDayCount, 1);
    },
  );
  testWidgets('today remains outlined when another date is selected', (
    tester,
  ) async {
    final today = CairoTime.local(DateTime.now());
    var selected = DateTime(today.year, today.month, today.day);
    await pumpSessionDesign(
      tester,
      () => Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SessionCalendar(
            date: selected,
            month: true,
            hasSessions: (_) => true,
            onDate: (date) => setState(() => selected = date),
          ),
        ),
      ),
    );
    final marker = find.byKey(const ValueKey('calendar-today-marker'));
    BoxDecoration decoration() =>
        tester.widget<Container>(marker).decoration! as BoxDecoration;
    expect(decoration().color, ColorManager.primary);
    final other = DateTime(today.year, today.month, today.day == 1 ? 2 : 1);
    await tester.tap(find.byKey(ValueKey('calendar-${CairoTime.date(other)}')));
    await tester.pumpAndSettle();
    expect(decoration().color, isNull);
    expect(decoration().border, Border.all(color: ColorManager.primary));
    expect(
      tester
          .widget<Text>(
            find.descendant(of: marker, matching: find.byType(Text)),
          )
          .style!
          .fontWeight,
      FontWeight.bold,
    );
    expect(tester.takeException(), isNull);
  });
}
