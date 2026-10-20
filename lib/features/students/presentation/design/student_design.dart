import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';

class StudentAsset extends StatelessWidget {
  const StudentAsset(this.file, {super.key});
  final String file;
  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/figma/students/$file');
}

class StudentTag extends StatelessWidget {
  const StudentTag({
    required this.label,
    this.positive,
    this.primary = false,
    this.icon = true,
    super.key,
  });
  final String label;
  final bool? positive;
  final bool primary, icon;
  @override
  Widget build(BuildContext context) {
    final color = positive == true
        ? ColorManager.successText
        : positive == false
        ? ColorManager.errorText
        : primary
        ? ColorManager.primaryDark
        : ColorManager.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p8,
        vertical: AppPadding.p4,
      ),
      decoration: BoxDecoration(
        color: positive == true
            ? ColorManager.successSurface
            : positive == false
            ? ColorManager.errorSurface
            : primary
            ? ColorManager.primaryBright
            : ColorManager.grey200,
        border: Border.all(
          width: 0.5,
          color: positive == true
              ? ColorManager.successBorder
              : positive == false
              ? ColorManager.errorBorder
              : primary
              ? ColorManager.primaryLight
              : ColorManager.stroke,
        ),
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon && positive != null) ...[
            StudentAsset(positive! ? '0b657.svg' : 'cc156.svg'),
            const SizedBox(width: AppSize.s4),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                height: 20 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
