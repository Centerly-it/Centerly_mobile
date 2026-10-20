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
    final today = CairoTime.date(CairoTime.local(DateTime.now()));
    final date = CairoTime.date(day);
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
      final session = SessionDesignData(
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
        completed: date.compareTo(today) < 0 || (date == today && i == 1),
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
      // A cancelled preview session makes the monthly marker reviewable.
      if (day.day == 28 && i == 4) {
        session.cancellationReason = 'design_low_students'.tr();
      }
      return session;
    });
  });
  List<SessionDesignData> range(DateTime from, DateTime to) => [
    for (
      var d = DateTime.utc(from.year, from.month, from.day);
      !d.isAfter(DateTime.utc(to.year, to.month, to.day));
      d = DateTime.utc(d.year, d.month, d.day + 1)
    )
      ...day(d),
  ];
}
