import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Student Profile — Academic tab
/// Shows exams table + assignments table, matching the Figma design exactly:
/// table header row then one row per record.
class StudentAcademicTab extends StatelessWidget {
  const StudentAcademicTab({required this.student, super.key});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final exams = CenterlyMockData.exams
        .where((e) => e.studentId == student.id)
        .toList();
    final assignments = CenterlyMockData.assignments
        .where((a) => a.studentId == student.id)
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
      children: [
        _SectionCard(
          icon: Icons.quiz_outlined,
          title: StringsManager.profileExamsTitle.tr(),
          child: exams.isEmpty
              ? _EmptyTableRow(label: StringsManager.profileNoExams.tr())
              : Column(
                  children: [
                    _TableHeader(
                      columns: [
                        StringsManager.profileColExam.tr(),
                        StringsManager.profileColDate.tr(),
                        StringsManager.profileColScore.tr(),
                      ],
                    ),
                    const Divider(height: AppSize.s1),
                    for (final exam in exams) _ExamRow(exam: exam),
                  ],
                ),
        ),
        const SizedBox(height: AppSize.s12),
        _SectionCard(
          icon: Icons.assignment_outlined,
          title: StringsManager.profileAssignmentsTitle.tr(),
          child: assignments.isEmpty
              ? _EmptyTableRow(label: StringsManager.profileNoAssignments.tr())
              : Column(
                  children: [
                    _TableHeader(
                      columns: [
                        StringsManager.profileColAssignment.tr(),
                        StringsManager.profileColDate.tr(),
                        StringsManager.profileColScore.tr(),
                      ],
                    ),
                    const Divider(height: AppSize.s1),
                    for (final a in assignments) _AssignmentRow(assignment: a),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
              ],
            ),
          ),
          const Divider(height: AppSize.s1),
          child,
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.columns});

  final List<String> columns;

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
            flex: 3,
            child: Text(columns[0], style: AppTextStyles.labelSmall),
          ),
          Expanded(
            flex: 2,
            child: Text(
              columns[1],
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              columns[2],
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamRow extends StatelessWidget {
  const _ExamRow({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(exam.scorePercent);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p14,
        vertical: AppPadding.p12,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(exam.title, style: AppTextStyles.titleSmall),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${exam.date.day} ${_monthKey(exam.date.month).tr()}',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${exam.scorePercent}%',
              style: AppTextStyles.titleSmall.copyWith(color: color),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  const _AssignmentRow({required this.assignment});

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _assignmentChip(assignment.status);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p14,
        vertical: AppPadding.p10,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(assignment.title, style: AppTextStyles.titleSmall),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${assignment.date.day} ${_monthKey(assignment.date.month).tr()}',
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
                  horizontal: AppPadding.p8,
                  vertical: AppPadding.p4,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(color: color),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTableRow extends StatelessWidget {
  const _EmptyTableRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p20),
      child: Text(
        label,
        style: AppTextStyles.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}

Color _scoreColor(int score) {
  if (score >= 80) return ColorManager.success;
  if (score >= 60) return ColorManager.warning;
  return ColorManager.error;
}

(String, Color) _assignmentChip(AssignmentStatus status) => switch (status) {
  AssignmentStatus.submitted => (
    StringsManager.assignmentSubmitted.tr(),
    ColorManager.success,
  ),
  AssignmentStatus.late => (
    StringsManager.assignmentLate.tr(),
    ColorManager.warning,
  ),
  AssignmentStatus.pending => (
    StringsManager.assignmentPending.tr(),
    ColorManager.error,
  ),
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
