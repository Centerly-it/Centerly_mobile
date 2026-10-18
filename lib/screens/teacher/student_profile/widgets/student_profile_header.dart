import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:centrally/screens/teacher/teacher_shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Student Profile Header — matches Figma exactly:
/// - Avatar on leading side
/// - Name and group
/// - Three chips: Account paid, Attendance rate, Level
class StudentProfileHeader extends StatelessWidget {
  const StudentProfileHeader({required this.student, super.key});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final group = CenterlyMockData.groupById(student.groupId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
      child: Column(
        children: [
          Row(
            children: [
              const StudentAvatar(radius: AppSize.s32),
              const SizedBox(width: AppSize.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: AppTextStyles.headlineSmall),
                    const SizedBox(height: AppSize.s4),
                    Text(group.name, style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSize.s16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusChip(
                  label: StringsManager.profileAttendancePaid.tr(),
                  icon: Icons.check_circle_outline,
                  color: ColorManager.success,
                ),
                const SizedBox(width: AppSize.s8),
                _StatusChip(
                  label: StringsManager.profileAttendanceRate.tr(
                    namedArgs: {'rate': '85'},
                  ),
                  color: ColorManager.primary,
                ),
                const SizedBox(width: AppSize.s8),
                _StatusChip(
                  label: student.levelTag,
                  color: ColorManager.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p12,
        vertical: AppPadding.p8,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
          if (icon != null) ...[
            const SizedBox(width: AppSize.s6),
            Icon(icon, size: AppSize.s14, color: color),
          ],
        ],
      ),
    );
  }
}
