import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Student Attendance Tab — matches Figma exactly:
/// - "ملخص الحضور" section with 3 stats (معدل الحضور, حضر, غاب)
/// - "سجل الحضور" section with list of attendance records (اليوم, التاريخ, الحالة)
class StudentAttendanceTab extends StatelessWidget {
  const StudentAttendanceTab({required this.student, super.key});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final records = CenterlyMockData.attendance
        .where((a) => a.studentId == student.id)
        .toList();

    final presentCount = records
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    final absentCount = records
        .where((a) => a.status == AttendanceStatus.absent)
        .length;
    final total = records.length;
    final attendanceRate = total == 0
        ? 0
        : (presentCount / total * 100).toInt();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
      children: [
        _SectionCard(
          icon: Icons.pie_chart_outline,
          title: StringsManager.profileAttendanceSummaryTitle.tr(),
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.p14),
            child: Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: StringsManager.profileStatAbsent.tr(),
                    value: StringsManager.profileAbsentSessions.tr(
                      namedArgs: {'count': '$absentCount'},
                    ),
                    valueColor: ColorManager.error,
                  ),
                ),
                const SizedBox(width: AppSize.s12),
                Expanded(
                  child: _StatBox(
                    label: StringsManager.profileStatPresent.tr(),
                    value: StringsManager.profilePresentOfTotal.tr(
                      namedArgs: {
                        'present': '$presentCount',
                        'total': '$total',
                      },
                    ),
                    valueColor: ColorManager.success,
                  ),
                ),
                const SizedBox(width: AppSize.s12),
                Expanded(
                  child: _StatBox(
                    label: StringsManager.profileStatRate.tr(),
                    value: '$attendanceRate%',
                    valueColor: ColorManager.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSize.s12),
        _SectionCard(
          icon: Icons.calendar_today_outlined,
          title: StringsManager.profileAttendanceLogTitle.tr(),
          child: records.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppPadding.p20),
                  child: Text(
                    StringsManager.profileNoAttendance.tr(),
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    const _TableHeader(),
                    const Divider(height: 1, color: ColorManager.divider),
                    for (final record in records) ...[
                      _AttendanceRow(record: record),
                      if (record != records.last)
                        const Divider(height: 1, color: ColorManager.divider),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: ColorManager.divider),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppPadding.p14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppPadding.p8),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: AppSize.s18,
                    color: ColorManager.primary,
                  ),
                ),
                const SizedBox(width: AppSize.s10),
                Text(title, style: AppTextStyles.titleMedium),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorManager.divider),
          child,
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.r8),
        border: Border.all(color: ColorManager.divider),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(height: AppSize.s4),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(color: valueColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p14,
        vertical: AppPadding.p10,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              StringsManager.profileColDay.tr(),
              style: AppTextStyles.labelSmall,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              StringsManager.profileColDate.tr(),
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              StringsManager.profileColStatus.tr(),
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.record});

  final Attendance record;

  @override
  Widget build(BuildContext context) {
    final session = CenterlyMockData.sessions.firstWhere(
      (s) => s.id == record.sessionId,
      orElse: () => CenterlyMockData.sessions.first,
    );

    final (label, color, icon) = _statusInfo(record.status);
    final dayKey = _dayKey(session.date.weekday);
    final monthKey = _monthKey(session.date.month);
    final dateStr = '${session.date.day} ${monthKey.tr()}';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p14,
        vertical: AppPadding.p12,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(dayKey.tr(), style: AppTextStyles.titleSmall),
          ),
          Expanded(
            flex: 3,
            child: Text(
              dateStr,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p12,
                  vertical: AppPadding.p4,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                  border: Border.all(color: color.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelSmall.copyWith(color: color),
                    ),
                    const SizedBox(width: AppSize.s4),
                    Icon(icon, size: AppSize.s14, color: color),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

(String, Color, IconData) _statusInfo(AttendanceStatus status) =>
    switch (status) {
      AttendanceStatus.present => (
        StringsManager.attendancePresent.tr(),
        ColorManager.success,
        Icons.check_circle_outline,
      ),
      AttendanceStatus.absent => (
        StringsManager.attendanceAbsent.tr(),
        ColorManager.error,
        Icons.cancel_outlined,
      ),
      AttendanceStatus.excused => (
        StringsManager.attendanceExcused.tr(),
        ColorManager.warning,
        Icons.info_outline,
      ),
      AttendanceStatus.notMarked => (
        StringsManager.attendanceNotMarked.tr(),
        ColorManager.grey500,
        Icons.help_outline,
      ),
    };

String _dayKey(int weekday) => switch (weekday) {
  1 => StringsManager.dayMonday,
  2 => StringsManager.dayTuesday,
  3 => StringsManager.dayWednesday,
  4 => StringsManager.dayThursday,
  5 => StringsManager.dayFriday,
  6 => StringsManager.daySaturday,
  _ => StringsManager.daySunday,
};

String _monthKey(int month) => switch (month) {
  1 => StringsManager.monthJanuary,
  2 => StringsManager.monthFebruary,
  3 => StringsManager.monthMarch,
  4 => StringsManager.monthApril,
  5 => StringsManager.monthMay,
  6 => StringsManager.monthJune,
  7 => StringsManager.monthJuly,
  8 => StringsManager.monthAugust,
  9 => StringsManager.monthSeptember,
  10 => StringsManager.monthOctober,
  11 => StringsManager.monthNovember,
  _ => StringsManager.monthDecember,
};
