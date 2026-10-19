import 'package:centrally/core/format/cairo_time.dart';
import 'package:centrally/features/sessions/presentation/session_date_controls.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Cairo winter, DST, midnight and transition are independent of device zone',
    () {
      expect(CairoTime.local(DateTime.utc(2026, 1, 1, 12)).hour, 14);
      expect(CairoTime.local(DateTime.utc(2026, 7, 1, 12)).hour, 15);
      expect(CairoTime.local(DateTime.utc(2026, 7, 1, 22)).day, 2);
      final before = CairoTime.local(DateTime.utc(2026, 4, 23, 21, 59));
      final after = CairoTime.local(DateTime.utc(2026, 4, 23, 22));
      expect(before.hour, 23);
      expect(after.hour, 1);
      expect(after.day, 24);
      final fall = CairoTime.local(DateTime.utc(2026, 10, 29, 21));
      expect(fall.day, 29);
      expect(fall.hour, 23);
      expect(fall.timeZoneOffset, const Duration(hours: 2));
    },
  );
  test('day/week/month ranges use calendar arithmetic and bounded dates', () {
    final (start, end) = sessionRange(DateTime(2026, 3, 1), SessionPeriod.week);
    expect(start.weekday, DateTime.sunday);
    expect(end.difference(start).inDays, 6);
    final (a, b) = sessionRange(DateTime(2024, 2, 12), SessionPeriod.month);
    expect(CairoTime.date(a), '2024-02-01');
    expect(CairoTime.date(b), '2024-02-29');
  });
}
