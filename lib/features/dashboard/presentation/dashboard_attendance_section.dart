import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../domain/dashboard_summary.dart';
import 'dashboard_metrics.dart';

/// A refresh-time snapshot of ongoing session marks, not unique occupancy.
class DashboardAttendanceSection extends StatelessWidget {
  const DashboardAttendanceSection({required this.data, super.key});
  final DashboardSummary data;
  @override
  Widget build(BuildContext context) {
    final synced = data.attendanceSyncedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dashboard_attendance_title'.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSize.s16),
        if (synced == null)
          Text('dashboard_attendance_unavailable'.tr())
        else ...[
          DashboardMetrics(
            twoColumns: true,
            values: {
              'attendance_present': '${data.attendance.present}',
              'dashboard_attendance_waiting': '${data.attendance.notMarked}',
              'attendance_absent': '${data.attendance.absent}',
              'attendance_excused': '${data.attendance.excused}',
            },
          ),
        ],
      ],
    );
  }
}
