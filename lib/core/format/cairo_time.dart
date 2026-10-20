import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

class CairoTime {
  CairoTime._();
  static final tz.Location _location = _initialize();
  static tz.Location _initialize() {
    data.initializeTimeZones();
    return tz.getLocation('Africa/Cairo');
  }

  static DateTime local(DateTime instant) =>
      tz.TZDateTime.from(instant, _location);
  static String time(DateTime instant, String locale) =>
      DateFormat('h:mm a', locale).format(local(instant));
  // Isolate each numeric time so Arabic day periods cannot cross the separator.
  static String range(DateTime start, DateTime end, String locale) =>
      '\u2066${time(start, locale)}\u2069 – \u2066${time(end, locale)}\u2069';
  static String date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
