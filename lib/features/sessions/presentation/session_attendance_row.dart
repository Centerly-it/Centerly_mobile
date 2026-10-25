import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../domain/attendance_record.dart';
import 'session_detail_header.dart';

class SessionAttendanceRow extends StatelessWidget {
  const SessionAttendanceRow({required this.row, super.key});
  final AttendanceRecord row;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
    child: TeacherCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: AppSize.s8),
              AppStatusBadge.attendance(status: row.status),
            ],
          ),
          const SizedBox(height: AppSize.s12),
          Text(
            'detail_actor'.tr(args: [row.marker ?? 'detail_not_recorded'.tr()]),
            style: AppTextStyles.metadata,
          ),
          if (row.markedAt != null)
            Text(
              'detail_marked'.tr(
                args: [detailTimestamp(row.markedAt!, context)],
              ),
              style: AppTextStyles.metadata,
            ),
        ],
      ),
    ),
  );
}
