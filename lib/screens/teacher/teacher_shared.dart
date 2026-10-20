import 'dart:ui' as ui;
import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/font_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/core/widgets/app_empty_state.dart';
import 'package:centrally/core/widgets/app_session_card.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TeacherPage extends StatelessWidget {
  const TeacherPage({
    required this.title,
    required this.child,
    super.key,
    this.actions,
    this.blueHeader = false,
    this.padding = const EdgeInsets.all(AppPadding.p16),
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool blueHeader;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: blueHeader
            ? ColorManager.primary
            : ColorManager.background,
        foregroundColor: blueHeader
            ? ColorManager.white
            : ColorManager.textPrimary,
        title: Text(title),
        actions: actions,
      ),
      body: Padding(padding: padding, child: child),
    );
  }
}

class TeacherSectionTitle extends StatelessWidget {
  const TeacherSectionTitle({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.headlineSmall)),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.chevron_left, size: AppSize.s18),
            label: Text(actionLabel!),
          ),
      ],
    );
  }
}

class TeacherCard extends StatelessWidget {
  const TeacherCard({
    required this.child,
    super.key,
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

class TeacherStatCard extends StatelessWidget {
  const TeacherStatCard({
    required this.title,
    required this.value,
    required this.color,
    super.key,
    this.icon,
    this.unit,
  });

  final String title;
  final String value;
  final Color color;
  final IconData? icon;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return TeacherCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            textDirection: unit == null ? null : ui.TextDirection.ltr,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (unit != null) ...[
                Text(
                  unit!,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeightManager.bold,
                  ),
                ),
                const SizedBox(width: AppSize.s4),
              ],
              if (icon != null) ...[
                Icon(icon, color: color, size: AppSize.s18),
                const SizedBox(width: AppSize.s4),
              ],
              Text(
                value,
                style: AppTextStyles.headlineLarge.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSize.s4),
          Text(
            title,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TeacherSearchField extends StatelessWidget {
  const TeacherSearchField({
    required this.hint,
    required this.onChanged,
    super.key,
  });

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: ColorManager.grey500),
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
    );
  }
}

/// Backward-compatible wrapper — delegates to [AppEmptyState] from core.
class TeacherEmptyState extends StatelessWidget {
  const TeacherEmptyState({
    required this.title,
    required this.subtitle,
    super.key,
    this.icon,
  });

  final String title;
  final String subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: ColorManager.primary,
    );
  }
}

/// Backward-compatible wrapper — delegates to [AppSessionCard] from core.
class TeacherSessionCard extends StatelessWidget {
  const TeacherSessionCard({
    required this.session,
    required this.onTap,
    super.key,
    this.highlight = false,
  });

  final Session session;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return AppSessionCard(session: session, onTap: onTap, highlight: highlight);
  }
}

class TeacherStatusChip extends StatelessWidget {
  const TeacherStatusChip({
    required this.label,
    required this.color,
    super.key,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      selectedColor: color,
      backgroundColor: ColorManager.grey200,
      labelStyle: AppTextStyles.labelSmall.copyWith(
        color: selected ? ColorManager.white : ColorManager.textPrimary,
      ),
      side: BorderSide(color: selected ? color : ColorManager.divider),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
    );
  }
}

class StudentAvatar extends StatelessWidget {
  const StudentAvatar({super.key, this.radius = AppSize.s18});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ColorManager.primaryBright,
      child: Icon(Icons.person, color: ColorManager.primary, size: radius),
    );
  }
}

String formatTime(DateTime value) {
  final hour = value.hour > 12 ? value.hour - 12 : value.hour;
  final suffix = value.hour >= 12 ? 'م' : 'ص';
  return '${hour.toString().padLeft(2, '0')}:00\n$suffix';
}

String attendanceLabel(AttendanceStatus status) => switch (status) {
  AttendanceStatus.present => StringsManager.attendancePresent.tr(),
  AttendanceStatus.absent => StringsManager.attendanceAbsent.tr(),
  AttendanceStatus.excused => StringsManager.attendanceExcused.tr(),
  AttendanceStatus.notMarked => StringsManager.attendanceNotMarked.tr(),
};

Color attendanceColor(AttendanceStatus status) => switch (status) {
  AttendanceStatus.present => ColorManager.success,
  AttendanceStatus.absent => ColorManager.error,
  AttendanceStatus.excused => ColorManager.warning,
  AttendanceStatus.notMarked => ColorManager.grey500,
};
