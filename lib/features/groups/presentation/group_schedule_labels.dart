import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../domain/group_record.dart';

const _days = [
  'day_sunday',
  'day_monday',
  'day_tuesday',
  'day_wednesday',
  'day_thursday',
  'day_friday',
  'day_saturday',
];

List<({String days, String time})> groupScheduleLabels(
  GroupRecord group,
  BuildContext context,
) {
  final grouped = <String, List<GroupSchedulePreview>>{};
  for (final schedule in group.schedules) {
    final key =
        '${schedule.start}|${schedule.end}|${schedule.from}|${schedule.to}';
    grouped.putIfAbsent(key, () => []).add(schedule);
  }
  return grouped.values.map((schedules) {
    final days = schedules.map((s) => s.weekday).toSet().toList()
      ..sort((a, b) => ((a + 1) % 7).compareTo((b + 1) % 7));
    final names = days.map((d) => _days[d].tr()).join(' - ');
    String clock(String value) {
      final parts = value.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateFormat(
        minute == 0 ? 'h' : 'h:mm',
        context.locale.toString(),
      ).format(DateTime(2000, 1, 1, hour, minute));
    }

    final arabic = context.locale.languageCode == 'ar';
    String period(String value) {
      final hour = int.parse(value.split(':').first);
      if (!arabic) return hour < 12 ? 'AM' : 'PM';
      return hour < 12 ? 'صباحًا' : 'مساءً';
    }

    final startPeriod = period(schedules.first.start);
    final endPeriod = period(schedules.first.end);
    final interval = startPeriod == endPeriod
        ? '${clock(schedules.first.start)} – ${clock(schedules.first.end)}'
        : '${clock(schedules.first.start)} $startPeriod – ${clock(schedules.first.end)} $endPeriod';

    return (
      days: names,
      time: startPeriod == endPeriod
          ? '\u2066( $interval )\u2069 $startPeriod'
          : '\u2066( $interval )\u2069',
    );
  }).toList();
}
