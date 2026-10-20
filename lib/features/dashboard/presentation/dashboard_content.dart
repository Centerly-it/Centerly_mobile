import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import 'dashboard_metrics.dart';
import 'dashboard_day_section.dart';
import '../domain/dashboard_summary.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    required this.data,
    required this.onDate,
    this.onChanged,
    super.key,
  });
  final DashboardSummary data;
  final VoidCallback? onChanged;
  final ValueChanged<DateTime> onDate;
  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(AppPadding.p16),
    children: [
      DashboardDaySection(data: data, onDate: onDate, onChanged: onChanged),
      const SizedBox(height: AppSize.s24),
      Text(
        'live_finance_snapshot'.tr(),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      DashboardMetrics(
        values: {
          'live_collected': data.collectedEgp,
          'live_outstanding': data.outstandingEgp,
        },
      ),
      const SizedBox(height: AppSize.s24),
      Text(
        'live_attendance_summary'.tr(),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      DashboardMetrics(
        values: {
          'attendance_present': '${data.attendance.present}',
          'attendance_absent': '${data.attendance.absent}',
          'attendance_excused': '${data.attendance.excused}',
          'attendance_not_marked': '${data.attendance.notMarked}',
        },
      ),
    ],
  );
}
