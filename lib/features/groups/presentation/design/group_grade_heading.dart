import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'group_design.dart';

class GroupGradeHeading extends StatelessWidget {
  const GroupGradeHeading({required this.grade, super.key});
  final int grade;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
    decoration: const BoxDecoration(
      border: BorderDirectional(
        start: BorderSide(color: ColorManager.primary, width: 3),
      ),
    ),
    child: Text(
      'group_design_grade_$grade'.tr(),
      style: AppTextStyles.headlineSmall.copyWith(
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}

class GroupGradeDivider extends StatelessWidget {
  const GroupGradeDivider({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: AppSize.s16,
    child: OverflowBox(
      minWidth: MediaQuery.sizeOf(context).width,
      maxWidth: MediaQuery.sizeOf(context).width,
      minHeight: 11,
      maxHeight: 11,
      child: const ColoredBox(color: GroupDesign.stroke),
    ),
  );
}
