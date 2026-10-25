import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/color_manager.dart';
import 'design/group_design.dart';
import 'live_group_detail.dart';
import '../domain/group_record.dart';
import '../../students/presentation/student_directory.dart';

class LiveGroupCard extends StatelessWidget {
  const LiveGroupCard({required this.group, required this.onGrade, super.key});
  final GroupRecord group;
  final VoidCallback onGrade;
  static const _days = [
    'day_sunday',
    'day_monday',
    'day_tuesday',
    'day_wednesday',
    'day_thursday',
    'day_friday',
    'day_saturday',
  ];

  List<({String days, String time})> _scheduleLabels(BuildContext context) {
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
          ? '${clock(schedules.first.start)} : ${clock(schedules.first.end)}'
          : '${clock(schedules.first.start)} $startPeriod : ${clock(schedules.first.end)} $endPeriod';

      return (
        days: '( $names )',
        time: startPeriod == endPeriod
            ? '\u2066( $interval )\u2069 $startPeriod'
            : '\u2066( $interval )\u2069',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppPadding.p12),
    child: GroupPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LiveGroupDetail(group: group),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const GroupAsset('cee4b.svg'),
              ],
            ),
          ),
          const SizedBox(height: AppSize.s8),
          Text(group.subject, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSize.s12),
          Wrap(
            spacing: AppSize.s12,
            runSpacing: AppSize.s8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p12,
                  vertical: AppPadding.p8,
                ),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  border: Border.all(color: ColorManager.primary.withAlpha(25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: AppSize.s18,
                      color: ColorManager.primary,
                    ),
                    const SizedBox(width: AppSize.s8),
                    Text(
                      'group_design_count'.tr(args: ['${group.students}']),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: ColorManager.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSize.s12),
          Container(
            padding: const EdgeInsets.all(AppPadding.p12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              border: Border.all(color: const Color(0xFFE8EBF0)),
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.schedule_outlined,
                  size: AppSize.s18,
                  color: ColorManager.primary,
                ),
                const SizedBox(width: AppSize.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (group.schedules.isEmpty)
                        Text(
                          'live_no_schedules'.tr(),
                          style: AppTextStyles.bodySmall,
                        ),
                      for (final label in _scheduleLabels(context))
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppPadding.p4,
                          ),
                          child: Wrap(
                            spacing: AppSize.s12,
                            runSpacing: AppSize.s8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(label.days, style: AppTextStyles.bodySmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppPadding.p8,
                                  vertical: AppPadding.p4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.r8,
                                  ),
                                ),
                                child: Text(
                                  label.time,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: ColorManager.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (group.schedulesTruncated) Text('live_schedule_preview'.tr()),
          const SizedBox(height: AppSize.s12),
          OutlinedButton.icon(
            icon: const Icon(Icons.people_outline, size: AppSize.s18),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    StudentDirectory(groupId: group.id, groupName: group.name),
              ),
            ),
            label: Text('live_view_students'.tr()),
          ),
        ],
      ),
    ),
  );
}
