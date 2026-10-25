import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/localization/translated_label.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/widgets/app_info_row.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../domain/student_membership.dart';
import 'design/student_design.dart';

class StudentMembershipCard extends StatelessWidget {
  const StudentMembershipCard({required this.row, super.key});
  final StudentMembership row;
  @override
  Widget build(BuildContext context) => TeacherCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.groups_outlined,
              color: ColorManager.primary,
              size: AppSize.s20,
            ),
            const SizedBox(width: AppSize.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.groupName, style: AppTextStyles.bodySemiBold),
                  const SizedBox(height: AppSize.s4),
                  Text(row.subject, style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: AppSize.s8),
            StudentTag(
              label: 'completion_${row.status}'.tr(),
              positive: row.status == 'active',
              icon: false,
            ),
          ],
        ),
        const SizedBox(height: AppSize.s8),
        const Divider(height: AppSize.s1),
        const SizedBox(height: AppSize.s4),
        AppInfoRow(
          label: translatedLabel(context, 'membership_joined_on'),
          icon: Icons.event_available_outlined,
          value: DateFormat.yMMMd(
            context.locale.toString(),
          ).format(CairoTime.local(row.joinedAt)),
          valueStyle: AppTextStyles.caption,
        ),
        if (row.leftAt != null)
          AppInfoRow(
            label: translatedLabel(context, 'membership_left_on'),
            icon: Icons.event_busy_outlined,
            value: DateFormat.yMMMd(
              context.locale.toString(),
            ).format(CairoTime.local(row.leftAt!)),
            valueStyle: AppTextStyles.caption,
          ),
        if (row.archivedAt != null)
          Text('completion_archived_group'.tr(), style: AppTextStyles.caption),
      ],
    ),
  );
}
