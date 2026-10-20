import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../screens/teacher/teacher_shared.dart';

class DashboardMetrics extends StatelessWidget {
  const DashboardMetrics({
    required this.values,
    this.twoColumns = false,
    super.key,
  });
  final Map<String, String> values;
  final bool twoColumns;
  Color _color(String key) => switch (key) {
    'attendance_present' ||
    'live_collected' ||
    'dashboard_month_collected' => ColorManager.success,
    'attendance_absent' => ColorManager.error,
    'attendance_excused' ||
    'live_outstanding' ||
    'dashboard_month_outstanding' => ColorManager.warning,
    'attendance_not_marked' ||
    'dashboard_attendance_waiting' => ColorManager.grey500,
    _ => ColorManager.primary,
  };
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final paired =
          twoColumns ||
          (constraints.maxWidth >= 340 &&
              MediaQuery.textScalerOf(context).scale(16) <= 24);
      final width = paired
          ? (constraints.maxWidth - AppSize.s12) / 2
          : constraints.maxWidth;
      return Wrap(
        spacing: AppSize.s12,
        runSpacing: AppSize.s12,
        children: [
          for (final entry in values.entries)
            SizedBox(
              width: width,
              child: TeacherStatCard(
                title: entry.key.tr(),
                value: entry.value,
                color: _color(entry.key),
                unit: entry.key == 'live_work_duration'
                    ? 'dashboard_hour_unit'.tr()
                    : null,
              ),
            ),
        ],
      );
    },
  );
}
