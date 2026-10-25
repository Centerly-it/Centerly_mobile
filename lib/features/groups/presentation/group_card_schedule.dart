import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../domain/group_record.dart';
import 'group_schedule_labels.dart';

class GroupCardSchedule extends StatelessWidget {
  const GroupCardSchedule({required this.group, super.key});
  final GroupRecord group;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppPadding.p8),
    decoration: BoxDecoration(
      color: ColorManager.primarySoft,
      borderRadius: BorderRadius.circular(AppRadius.r12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (group.schedules.isEmpty)
          Text('live_no_schedules'.tr(), style: AppTextStyles.bodySmall),
        for (final label in groupScheduleLabels(group, context))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: AppSize.s18,
                  color: ColorManager.primary,
                ),
                const SizedBox(width: AppSize.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label.days, style: AppTextStyles.bodySemiBold),
                      const SizedBox(height: AppSize.s4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.schedule_outlined,
                            size: AppSize.s16,
                            color: ColorManager.textSecondary,
                          ),
                          const SizedBox(width: AppSize.s8),
                          Expanded(
                            child: Text(
                              label.time,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (group.schedulesTruncated)
          Text('live_schedule_preview'.tr(), style: AppTextStyles.caption),
      ],
    ),
  );
}
