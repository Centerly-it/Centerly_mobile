import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/secretary/data_management/add_edit_group_screen.dart';
import 'package:centrally/screens/secretary/data_management/enter_grades_assignments_screen.dart';
import 'package:centrally/screens/secretary/data_management/group_enrollment_screen.dart';
import 'package:centrally/screens/teacher/teacher_shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Groups screen — matches Figma:
/// - White AppBar "المجموعات" centered (with + Add button for Secretary)
/// - Search field
/// - Grade level header with left blue border accent
/// - Group cards: name + schedule + capacity + next session grey bar
class TeacherGroupsScreen extends StatefulWidget {
  const TeacherGroupsScreen({this.role = UserRole.teacher, super.key});

  final UserRole role;

  @override
  State<TeacherGroupsScreen> createState() => _TeacherGroupsScreenState();
}

class _TeacherGroupsScreenState extends State<TeacherGroupsScreen> {
  String _query = '';

  void _onGroupTap(Group group) {
    if (widget.role != UserRole.secretary) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: ColorManager.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppPadding.p16,
            0,
            AppPadding.p16,
            AppPadding.p24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${group.name} - ${group.subjectName}',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: AppSize.s16),
              ListTile(
                leading: const Icon(
                  Icons.group_outlined,
                  color: ColorManager.primary,
                ),
                title: Text(
                  StringsManager.dataMgmtEnrollmentTitle.tr(),
                  style: AppTextStyles.titleSmall,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (_) => GroupEnrollmentScreen(group: group),
                        ),
                      )
                      .then((_) => setState(() {}));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit_note_outlined,
                  color: ColorManager.warning,
                ),
                title: Text(
                  StringsManager.dataMgmtGradesAssignmentsTitle.tr(),
                  style: AppTextStyles.titleSmall,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (_) => EnterGradesAssignmentsScreen(
                            preselectedGroupId: group.id,
                          ),
                        ),
                      )
                      .then((_) => setState(() {}));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: ColorManager.success,
                ),
                title: Text(
                  StringsManager.dataMgmtEditGroupTitle.tr(),
                  style: AppTextStyles.titleSmall,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (_) => AddEditGroupScreen(group: group),
                        ),
                      )
                      .then((_) => setState(() {}));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = CenterlyMockData.groups.where((g) {
      final text = '${g.name} ${g.subjectName} ${g.gradeLevelName}'
          .toLowerCase();
      return text.contains(_query.trim().toLowerCase());
    }).toList();

    final gradeLevels = filteredGroups
        .map((g) => g.gradeLevelName)
        .toSet()
        .toList();

    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorManager.surface,
        title: Text(
          StringsManager.groupsTitle.tr(),
          style: AppTextStyles.headlineSmall,
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (widget.role == UserRole.secretary)
            IconButton(
              icon: const Icon(Icons.add, color: ColorManager.primary),
              tooltip: StringsManager.dataMgmtAddGroupTitle.tr(),
              onPressed: () => Navigator.of(context)
                  .push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AddEditGroupScreen(),
                    ),
                  )
                  .then((_) => setState(() {})),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppPadding.p16,
              AppPadding.p12,
              AppPadding.p16,
              AppPadding.p8,
            ),
            child: TeacherSearchField(
              hint: StringsManager.groupsSearchHint.tr(),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: filteredGroups.isEmpty
                ? TeacherEmptyState(
                    title: StringsManager.groupsEmptyTitle.tr(),
                    subtitle: StringsManager.groupsEmptySubtitle.tr(),
                    icon: Icons.groups_2_outlined,
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p16,
                      vertical: AppPadding.p8,
                    ),
                    children: [
                      for (final grade in gradeLevels) ...[
                        _GradeLevelHeader(label: grade),
                        const SizedBox(height: AppSize.s12),
                        for (final group in filteredGroups.where(
                          (g) => g.gradeLevelName == grade,
                        )) ...[
                          _GroupCard(
                            group: group,
                            onTap: () => _onGroupTap(group),
                          ),
                          const SizedBox(height: AppSize.s10),
                        ],
                        const SizedBox(height: AppSize.s8),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Grade Level Header with left blue accent ──────────────────────────────────

class _GradeLevelHeader extends StatelessWidget {
  const _GradeLevelHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.titleMedium)),
          Container(
            width: AppSize.s4,
            decoration: const BoxDecoration(
              color: ColorManager.primary,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(AppRadius.r4),
                bottomRight: Radius.circular(AppRadius.r4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Group Card ────────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, this.onTap});

  final Group group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      child: TeacherCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.name, style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSize.s10),
            _InfoLine(
              icon: Icons.calendar_today_outlined,
              text: group.scheduleLabel,
            ),
            const SizedBox(height: AppSize.s6),
            _InfoLine(
              icon: Icons.people_outline,
              text:
                  '${group.capacity} ${StringsManager.groupsStudentsLabel.tr()}',
            ),
            const SizedBox(height: AppSize.s12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p12,
                vertical: AppPadding.p10,
              ),
              decoration: BoxDecoration(
                color: ColorManager.grey200,
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
              child: Wrap(
                spacing: AppSize.s6,
                runSpacing: AppSize.s6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    StringsManager.groupsNextSession.tr(),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: ColorManager.primary,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: AppSize.s16,
                    color: ColorManager.grey500,
                  ),
                  const SizedBox(width: AppSize.s4),
                  Text(
                    _formatDate(group.nextSessionAt),
                    style: AppTextStyles.labelSmall,
                  ),
                  const SizedBox(width: AppSize.s12),
                  const Icon(
                    Icons.schedule_outlined,
                    size: AppSize.s16,
                    color: ColorManager.grey500,
                  ),
                  const SizedBox(width: AppSize.s4),
                  Text(
                    _formatTimeShort(group.nextSessionAt),
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSize.s16, color: ColorManager.grey500),
        const SizedBox(width: AppSize.s8),
        Text(text, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

String _formatDate(DateTime dt) {
  final monthKey = _monthKey(dt.month);
  return '${dt.day} ${monthKey.tr()}';
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

String _formatTimeShort(DateTime dt) {
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final suffix = dt.hour >= 12 ? 'م' : 'ص';
  return '${hour.toString().padLeft(2, '0')}:00 $suffix';
}
