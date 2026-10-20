import 'package:easy_localization/easy_localization.dart';
import '../../../core/format/cairo_time.dart';
import '../domain/session_design_data.dart';

/// Explicit design-review fixture. Never queries or mutates a server.
class SessionDesignFixture {
  final Map<String, List<SessionDesignData>> _days = {};
  List<SessionDesignData> day(
    DateTime day,
  ) => _days.putIfAbsent(CairoTime.date(day), () {
    if (day.weekday == DateTime.friday) return [];
    final locale = Intl.getCurrentLocale();
    return List.generate(5, (i) {
      final group = 'design_group'.tr(args: ['${i + 1}']);
      final offset = CairoTime.local(
        DateTime.utc(day.year, day.month, day.day, 12),
      ).timeZoneOffset;
      final start = DateTime.utc(
        day.year,
        day.month,
        day.day,
        10 + i * 2,
      ).subtract(offset);
      return SessionDesignData(
        id: '${CairoTime.date(day)}-$i',
        date: day,
        start: start,
        end: start.add(const Duration(minutes: 90)),
        group: group,
        subject: 'design_physics'.tr(),
        grade: 'design_grade'.tr(),
        current:
            i == 0 &&
            CairoTime.date(day) ==
                CairoTime.date(CairoTime.local(DateTime.now())),
        students: List.generate(
          25,
          (n) => SessionStudentData(
            id: '$i-$n',
            name:
                '${'design_student_name'.tr()} ${NumberFormat.decimalPattern(locale).format(n + 1)}',
            group: group,
            status: n < 19
                ? 'present'
                : n < 23
                ? 'absent'
                : 'excused',
          ),
        ),
      );
    });
  });
  List<SessionDesignData> range(DateTime from, DateTime to) => [
    for (var d = from; !d.isAfter(to); d = d.add(const Duration(days: 1)))
      ...day(d),
  ];
}
