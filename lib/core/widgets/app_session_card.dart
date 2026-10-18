import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/core/widgets/app_status_badge.dart';
import 'package:centrally/mock_data/centerly_mock_data.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Role-aware session card — promoted from TeacherSessionCard in teacher_shared.dart.
/// Used identically in teacher and secretary session lists.
class AppSessionCard extends StatelessWidget {
  const AppSessionCard({
    required this.session,
    required this.onTap,
    super.key,
    this.highlight = false,
    this.showStatusBadge = false,
  });

  final Session session;
  final VoidCallback onTap;

  /// Highlights the time box in primary color (e.g. today's ongoing session).
  final bool highlight;

  /// If true, shows the session status as a badge instead of the time box accent.
  final bool showStatusBadge;

  @override
  Widget build(BuildContext context) {
    final group = CenterlyMockData.groupById(session.groupId);
    final presentCount = CenterlyMockData.attendanceForSession(
      session.id,
    ).where((item) => item.status == AttendanceStatus.present).length;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      child: _AppCard(
        padding: const EdgeInsets.all(AppPadding.p14),
        child: Row(
          children: [
            if (showStatusBadge)
              AppStatusBadge.session(status: session.status)
            else
              Container(
                width: AppSize.s48,
                padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
                decoration: BoxDecoration(
                  color: highlight
                      ? ColorManager.primary
                      : ColorManager.grey200,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Text(
                  _formatTime(session.startTime),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: highlight
                        ? ColorManager.white
                        : ColorManager.textSecondary,
                  ),
                ),
              ),
            const SizedBox(width: AppSize.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${group.name} - ${group.subjectName}',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSize.s4),
                  Text(
                    '$presentCount/${session.expectedStudentsCount}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: ColorManager.success,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              StringsManager.sessionDurationLabel.tr(
                namedArgs: {'count': '${session.expectedStudentsCount ~/ 10}'},
              ),
              style: AppTextStyles.labelLarge.copyWith(
                color: ColorManager.primary,
              ),
            ),
            const SizedBox(width: AppSize.s8),
            const Icon(Icons.chevron_left, color: ColorManager.grey500),
          ],
        ),
      ),
    );
  }
}

/// Internal card container — mirrors TeacherCard from teacher_shared.dart.
/// Defined here so AppSessionCard has no dependency on teacher_shared.
class _AppCard extends StatelessWidget {
  const _AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppPadding.p16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorManager.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: ColorManager.divider),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

String _formatTime(DateTime value) {
  final hour = value.hour > 12 ? value.hour - 12 : value.hour;
  final suffix = value.hour >= 12 ? 'م' : 'ص';
  return '${hour.toString().padLeft(2, '0')}:00\n$suffix';
}
