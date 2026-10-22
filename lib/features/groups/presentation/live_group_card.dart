import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
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
          Text(group.subject),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ActionChip(label: Text(group.gradeName), onPressed: onGrade),
          ),
          Text(
            'live_group_students'.tr(
              namedArgs: {
                'count': '${group.students}',
                'capacity': '${group.capacity}',
              },
            ),
          ),
          if (group.schedules.isEmpty) Text('live_no_schedules'.tr()),
          if (group.schedules.isNotEmpty) Text('live_cairo_time'.tr()),
          for (final schedule in group.schedules)
            Text(
              '${_days[schedule.weekday].tr()} ${schedule.start} – ${schedule.end}\n'
              '${schedule.from} – ${schedule.to ?? 'live_open_schedule'.tr()}',
            ),
          if (group.schedulesTruncated) Text('live_schedule_preview'.tr()),
          if (group.roster.isNotEmpty) ...[
            const SizedBox(height: AppSize.s8),
            GroupIconLabel(
              asset: '263e2.svg',
              label: 'live_roster_preview'.tr(),
            ),
            for (final student in group.roster) Text(student.name),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    StudentDirectory(groupId: group.id, groupName: group.name),
              ),
            ),
            child: Text('live_view_students'.tr()),
          ),
        ],
      ),
    ),
  );
}
