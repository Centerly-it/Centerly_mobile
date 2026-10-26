import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_info_row.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../../students/presentation/design/student_design.dart';
import '../domain/secretary_record.dart';

class SecretaryCard extends StatelessWidget {
  const SecretaryCard({required this.record, this.action, super.key});
  final SecretaryRecord record;
  final Widget? action;
  @override
  Widget build(BuildContext context) => TeacherCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: ColorManager.primaryBright,
              child: Icon(
                Icons.support_agent_rounded,
                color: ColorManager.primary,
              ),
            ),
            const SizedBox(width: AppSize.s12),
            Expanded(
              child: Text(record.name, style: AppTextStyles.titleMedium),
            ),
            const SizedBox(width: AppSize.s8),
            StudentTag(
              label: 'completion_${record.status}'.tr(),
              positive: record.status == 'active',
              icon: false,
            ),
          ],
        ),
        const SizedBox(height: AppSize.s12),
        const Divider(),
        AppInfoRow(
          label: 'login_email_label'.tr(),
          value: record.email,
          icon: Icons.mail_outline,
          selectable: true,
        ),
        AppInfoRow(
          label: 'data_mgmt_phone'.tr(),
          value: record.phone?.trim().isNotEmpty == true
              ? record.phone!
              : 'secretary_phone_missing'.tr(),
          icon: Icons.phone_outlined,
          selectable: true,
        ),
        if (record.requestStatus != null) ...[
          const Divider(),
          Text(
            'completion_removal_${record.requestStatus}'.tr(),
            style: AppTextStyles.bodySmall,
          ),
        ],
        if (record.requestedAt != null)
          Text(
            'completion_requested_at'.tr(
              args: [CairoTime.date(CairoTime.local(record.requestedAt!))],
            ),
            style: AppTextStyles.metadata,
          ),
        if (record.handledAt != null)
          Text(
            'completion_handled_at'.tr(
              args: [CairoTime.date(CairoTime.local(record.handledAt!))],
            ),
            style: AppTextStyles.metadata,
          ),
        if (action != null) ...[
          const SizedBox(height: AppSize.s12),
          const Divider(),
          Align(alignment: AlignmentDirectional.centerEnd, child: action!),
        ],
      ],
    ),
  );
}
