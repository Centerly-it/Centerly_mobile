import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/core/widgets/app_bottom_sheet.dart';
import 'package:centrally/core/widgets/app_status_badge.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/secretary/secretary_attendance_sheet_screen.dart';
import 'package:centrally/screens/teacher/student_profile/teacher_student_profile_screen.dart';
import 'package:centrally/screens/teacher/teacher_attendance_sheet_screen.dart';
import 'package:centrally/screens/teacher/teacher_shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Session Details Screen — matches Figma:
/// - AppBar: Session Details, back arrow
/// - Header card: group name + duration, time, date, avatar icon button
/// - Two stat cards: Present / Expected
/// - TabBar: Present / Absent
/// - Student list with avatar + name + group + status chip
/// - Open Attendance Sheet filled button
/// - Cancel Session text button
/// - Footer note
class TeacherSessionDetailsScreen extends StatefulWidget {
  const TeacherSessionDetailsScreen({
    required this.session,
    this.role = UserRole.teacher,
    super.key,
  });

  final Session session;
  final UserRole role;

  @override
  State<TeacherSessionDetailsScreen> createState() =>
      _TeacherSessionDetailsScreenState();
}

class _TeacherSessionDetailsScreenState
    extends State<TeacherSessionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAttendanceSheet() {
    if (widget.role == UserRole.secretary) {
      Navigator.of(context)
          .push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  SecretaryAttendanceSheetScreen(session: widget.session),
            ),
          )
          .then((_) => setState(() {}));
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TeacherAttendanceSheetScreen(session: widget.session),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allAttendance = CenterlyMockData.attendanceForSession(
      widget.session.id,
    );
    final present = allAttendance
        .where((a) => a.status == AttendanceStatus.present)
        .toList();
    final absent = allAttendance
        .where(
          (a) =>
              a.status == AttendanceStatus.absent ||
              a.status == AttendanceStatus.notMarked,
        )
        .toList();

    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        backgroundColor: ColorManager.background,
        leading: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          StringsManager.sessionDetailsTitle.tr(),
          style: AppTextStyles.headlineSmall,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
              child: Column(
                children: [
                  const SizedBox(height: AppSize.s8),
                  _SessionHeaderCard(session: widget.session),
                  const SizedBox(height: AppSize.s16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_outline,
                          value: present.length.toString(),
                          label: StringsManager.sessionStatPresent.tr(),
                          color: ColorManager.success,
                        ),
                      ),
                      const SizedBox(width: AppSize.s12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people_outline,
                          value: widget.session.expectedStudentsCount
                              .toString(),
                          label: StringsManager.sessionStatExpected.tr(),
                          color: ColorManager.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.s16),
                  TabBar(
                    controller: _tabController,
                    labelColor: ColorManager.primary,
                    unselectedLabelColor: ColorManager.textSecondary,
                    indicatorColor: ColorManager.primary,
                    tabs: [
                      Tab(
                        text: StringsManager.sessionTabPresent.tr(
                          namedArgs: {'count': present.length.toString()},
                        ),
                      ),
                      Tab(
                        text: StringsManager.sessionTabAbsent.tr(
                          namedArgs: {'count': absent.length.toString()},
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _StudentAttendanceList(
                          items: present,
                          emptyLabel: StringsManager.sessionEmptyPresent.tr(),
                        ),
                        _StudentAttendanceList(
                          items: absent,
                          emptyLabel: StringsManager.sessionEmptyAbsent.tr(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomActions(
            onOpenSheet: _openAttendanceSheet,
            onCancel: () => _showCancelSheet(context),
          ),
        ],
      ),
    );
  }
}

// ── Session header card ───────────────────────────────────────────────────────

class _SessionHeaderCard extends StatelessWidget {
  const _SessionHeaderCard({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final group = CenterlyMockData.groupById(session.groupId);
    return TeacherCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${group.name} - ${group.subjectName}',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(width: AppSize.s8),
                    Text(
                      StringsManager.sessionDurationLabel.tr(
                        namedArgs: {
                          'count': '${session.expectedStudentsCount ~/ 10}',
                        },
                      ),
                      style: AppTextStyles.titleSmall.copyWith(
                        color: ColorManager.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSize.s6),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: AppSize.s14,
                      color: ColorManager.grey500,
                    ),
                    const SizedBox(width: AppSize.s4),
                    Text(
                      '${session.startTime.hour}:00 - ${session.endTime.hour}:00',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSize.s4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: AppSize.s14,
                      color: ColorManager.grey500,
                    ),
                    const SizedBox(width: AppSize.s4),
                    Text(
                      '${session.date.day} ${_monthKey(session.date.month).tr()} ${session.date.year}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: AppSize.s36,
            height: AppSize.s36,
            decoration: BoxDecoration(
              color: ColorManager.primaryBright,
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              color: ColorManager.primary,
              size: AppSize.s20,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TeacherCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: AppSize.s20),
          const SizedBox(width: AppSize.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.headlineMedium.copyWith(color: color),
              ),
              Text(label, style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Student attendance list ───────────────────────────────────────────────────

class _StudentAttendanceList extends StatelessWidget {
  const _StudentAttendanceList({required this.items, required this.emptyLabel});

  final List<Attendance> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return TeacherEmptyState(
        title: emptyLabel,
        subtitle: '',
        icon: Icons.person_search_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: AppSize.s1),
      itemBuilder: (context, index) {
        final item = items[index];
        final student = CenterlyMockData.studentById(item.studentId);
        final group = CenterlyMockData.groupById(student.groupId);
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const StudentAvatar(radius: AppSize.s20),
          title: Text(student.name, style: AppTextStyles.titleSmall),
          subtitle: Text(group.name, style: AppTextStyles.labelSmall),
          trailing: AppStatusBadge.attendance(status: item.status),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TeacherStudentProfileScreen(student: student),
            ),
          ),
        );
      },
    );
  }
}

// _StatusChip replaced by AppStatusBadge.attendance — see usage in _StudentAttendanceList

// ── Bottom action buttons ─────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onOpenSheet, required this.onCancel});

  final VoidCallback onOpenSheet;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManager.surface,
      padding: const EdgeInsets.fromLTRB(
        AppPadding.p16,
        AppPadding.p12,
        AppPadding.p16,
        AppPadding.p24,
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpenSheet,
              icon: const Icon(Icons.assignment_outlined),
              label: Text(StringsManager.sessionOpenSheet.tr()),
            ),
          ),
          const SizedBox(height: AppSize.s12),
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.delete_outline, color: ColorManager.error),
            label: Text(
              StringsManager.sessionCancelButton.tr(),
              style: AppTextStyles.titleMedium.copyWith(
                color: ColorManager.error,
              ),
            ),
          ),
          const SizedBox(height: AppSize.s4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: AppSize.s14,
                color: ColorManager.grey500,
              ),
              const SizedBox(width: AppSize.s4),
              Text(
                StringsManager.sessionCancelNote.tr(),
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Cancel session bottom sheet ───────────────────────────────────────────────

Future<void> _showCancelSheet(BuildContext context) async {
  await AppBottomSheet.show<void>(
    context: context,
    child: const _CancelSessionSheet(),
  );
}

class _CancelSessionSheet extends StatefulWidget {
  const _CancelSessionSheet();

  @override
  State<_CancelSessionSheet> createState() => _CancelSessionSheetState();
}

class _CancelSessionSheetState extends State<_CancelSessionSheet> {
  String? _reason = 'other';
  final _textController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_reason == null) {
      setState(() => _error = StringsManager.cancelValidationChoose.tr());
      return;
    }
    if (_reason == 'other' && _textController.text.trim().isEmpty) {
      setState(() => _error = StringsManager.cancelValidationWrite.tr());
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(StringsManager.cancelSuccessMessage.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          StringsManager.cancelSessionTitle.tr(),
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: AppSize.s20),
        _CancelReason(
          value: 'low_attendance',
          groupValue: _reason,
          label: StringsManager.cancelLowAttendance.tr(),
          icon: Icons.people_outline,
          iconColor: ColorManager.warning,
          onChanged: (v) => setState(() => _reason = v),
        ),
        _CancelReason(
          value: 'technical_issue',
          groupValue: _reason,
          label: StringsManager.cancelTechnicalIssue.tr(),
          icon: Icons.block_outlined,
          iconColor: ColorManager.error,
          onChanged: (v) => setState(() => _reason = v),
        ),
        _CancelReason(
          value: 'other',
          groupValue: _reason,
          label: StringsManager.cancelOther.tr(),
          icon: Icons.chat_bubble_outline,
          iconColor: ColorManager.primary,
          onChanged: (v) => setState(() => _reason = v),
        ),
        if (_reason == 'other') ...[
          const SizedBox(height: AppSize.s8),
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: StringsManager.cancelReasonHint.tr(),
              fillColor: ColorManager.grey200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSize.s8),
          Text(
            _error!,
            style: AppTextStyles.labelSmall.copyWith(color: ColorManager.error),
          ),
        ],
        const SizedBox(height: AppSize.s20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(backgroundColor: ColorManager.error),
            child: Text(StringsManager.cancelSubmit.tr()),
          ),
        ),
        const SizedBox(height: AppSize.s10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(StringsManager.cancelBack.tr()),
          ),
        ),
        const SizedBox(height: AppSize.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: AppSize.s14,
              color: ColorManager.grey500,
            ),
            const SizedBox(width: AppSize.s4),
            Text(
              StringsManager.cancelNotifyNote.tr(),
              style: AppTextStyles.labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _CancelReason extends StatelessWidget {
  const _CancelReason({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onChanged,
  });

  final String value;
  final String? groupValue;
  final String label;
  final IconData icon;
  final Color iconColor;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.p10),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(AppRadius.r12),
        child: Container(
          padding: const EdgeInsets.all(AppPadding.p12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.r12),
            border: Border.all(color: ColorManager.divider),
          ),
          child: Row(
            children: [
              // ignore: deprecated_member_use
              Radio<String>(
                value: value,
                // ignore: deprecated_member_use
                groupValue: groupValue,
                // ignore: deprecated_member_use
                onChanged: onChanged,
              ),
              const SizedBox(width: AppSize.s8),
              Expanded(child: Text(label, style: AppTextStyles.titleSmall)),
              Icon(icon, color: iconColor, size: AppSize.s24),
            ],
          ),
        ),
      ),
    );
  }
}

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
