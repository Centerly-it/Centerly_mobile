import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_info_row.dart';
import '../../../core/localization/translated_label.dart';
import '../../students/presentation/design/student_design.dart';
import '../../sessions/presentation/session_detail_page.dart';
import '../domain/student_attendance_record.dart';
import 'attendance_history_notice.dart';

class AttendanceHistoryRow extends StatelessWidget {
  const AttendanceHistoryRow({required this.record, super.key});
  final StudentAttendanceRecord record;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: ColorManager.stroke)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.event_available_outlined,
              size: AppSize.s18,
              color: ColorManager.primary,
            ),
            const SizedBox(width: AppSize.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.group ?? 'live_missing_value'.tr(),
                    style: AppTextStyles.bodySemiBold,
                  ),
                  const SizedBox(height: AppSize.s4),
                  Text(
                    DateFormat.yMMMd(
                      context.locale.toString(),
                    ).format(DateTime.parse(record.date)),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSize.s8),
            StudentTag(
              label: 'attendance_${record.status}'.tr(),
              positive:
                  record.status == 'not_marked' || record.status == 'excused'
                  ? null
                  : record.status == 'present',
              icon: false,
            ),
          ],
        ),
        AppInfoRow(
          label: translatedLabel(context, 'ui_recorded_by'),
          icon: Icons.person_outline,
          value: record.actor ?? 'live_missing_value'.tr(),
          valueStyle: AppTextStyles.caption,
        ),
        if (record.sessionStatus == 'cancelled')
          const AttendanceHistoryNotice(),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: () => SessionDetailPage.open(context, record.sessionId),
            icon: const Icon(Icons.open_in_new, size: AppSize.s16),
            label: Text(
              'session_details_title'.tr(),
              style: AppTextStyles.caption,
            ),
          ),
        ),
      ],
    ),
  );
}
