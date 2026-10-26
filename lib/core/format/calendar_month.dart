import 'cairo_time.dart';

/// Calendar dates, not a rolling 30-day window. The server applies Cairo midnight.
Map<String, dynamic> calendarMonthDates(DateTime date) => {
  'p_from': CairoTime.date(DateTime.utc(date.year, date.month)),
  'p_to': CairoTime.date(DateTime.utc(date.year, date.month + 1, 0)),
};
