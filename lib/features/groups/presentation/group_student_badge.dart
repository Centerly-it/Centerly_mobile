import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/color_manager.dart';
import '../domain/group_record.dart';

class GroupStudentBadge extends StatelessWidget {
  const GroupStudentBadge({required this.group, super.key});
  final GroupRecord group;
  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p12,
        vertical: AppPadding.p4,
      ),
      decoration: BoxDecoration(
        color: ColorManager.primaryBright,
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.people_outline,
            size: AppSize.s18,
            color: ColorManager.primary,
          ),
          const SizedBox(width: AppSize.s8),
          Flexible(
            child: Text(
              'group_design_count'.tr(args: ['${group.students}']),
              style: AppTextStyles.labelSmall.copyWith(
                color: ColorManager.primary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
