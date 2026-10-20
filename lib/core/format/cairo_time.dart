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
      _clock(local(instant), locale);
  // Each clock stays LTR; the interval follows the reading direction.
  static String range(DateTime start, DateTime end, String locale) =>
      _interval(time(start, locale), time(end, locale), locale);

  /// Legacy mock schedules store local wall-clock fields, not UTC instants.
  static String clockRange(DateTime start, DateTime end, String locale) =>
      _interval(_clock(start, locale), _clock(end, locale), locale);

  static String _clock(DateTime value, String locale) {
    if (!_isArabic(locale)) return DateFormat('h:mm a', locale).format(value);
    final digits = DateFormat('h:mm', locale).format(value);
    final period = DateFormat('a', locale).format(value);
    // RTL clock: numeric digits on the right, day period on the left.
    return '\u2067\u2066$digits\u2069 $period\u2069';
  }

  static bool _isArabic(String locale) =>
      locale.split(RegExp('[-_]')).first == 'ar';

  static String _interval(String start, String end, String locale) {
    final clocks = '\u2066$start\u2069 – \u2066$end\u2069';
    return _isArabic(locale) ? '\u2067$clocks\u2069' : '\u2066$clocks\u2069';
  }

  static String date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
