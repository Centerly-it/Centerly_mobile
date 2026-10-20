import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../preview/group_preview_data.dart';
import 'group_design.dart';

class GroupInfoHeader extends StatelessWidget {
  const GroupInfoHeader({required this.data, super.key});
  final GroupPreviewData data;
  @override
  Widget build(BuildContext context) => GroupPanel(
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppPadding.p8),
          decoration: BoxDecoration(
            color: ColorManager.primaryBright,
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          child: const GroupAsset('7b2bc.svg'),
        ),
        const SizedBox(width: AppSize.s12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${data.name} - ${'design_physics'.tr()}  ',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'group_design_short_grade'.tr(args: ['${data.grade}']),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: ColorManager.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
