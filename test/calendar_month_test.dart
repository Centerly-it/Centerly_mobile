import 'package:flutter_test/flutter_test.dart';
import 'package:centrally/core/format/calendar_month.dart';
import 'package:centrally/core/format/cairo_time.dart';

void main() {
  for (final c in [
    (2026, 10, 31),
    (2026, 9, 30),
    (2026, 2, 28),
    (2028, 2, 29),
    (2026, 12, 31),
  ]) {
    test('calendar month ${c.$1}-${c.$2} has exactly ${c.$3} days', () {
      final month = '${c.$1}-${c.$2.toString().padLeft(2, '0')}';
      expect(calendarMonthDates(DateTime.utc(c.$1, c.$2, 15)), {
        'p_from': '$month-01',
        'p_to': '$month-${c.$3}',
      });
    });
  }
  test(
    'current month follows Cairo even when UTC is still the preceding month',
    () {
      final now = CairoTime.local(DateTime.parse('2026-09-30T21:30:00Z'));
      expect(calendarMonthDates(now), {
        'p_from': '2026-10-01',
        'p_to': '2026-10-31',
      });
    },
  );
}
