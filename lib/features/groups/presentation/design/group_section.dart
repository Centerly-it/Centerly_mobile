import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'group_design.dart';

class GroupSection extends StatelessWidget {
  const GroupSection({
    required this.title,
    required this.asset,
    required this.child,
    this.onViewAll,
    super.key,
  });
  final String title, asset;
  final Widget child;
  final VoidCallback? onViewAll;
  @override
  Widget build(BuildContext context) => GroupPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppPadding.p8),
              decoration: const BoxDecoration(
                color: ColorManager.primaryBright,
                shape: BoxShape.circle,
              ),
              child: GroupAsset(asset),
            ),
            const SizedBox(width: AppSize.s12),
            Expanded(
              child: Text(title.tr(), style: AppTextStyles.bodySemiBold),
            ),
            if (onViewAll != null)
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onViewAll,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'group_design_view_all'.tr(),
                      style: AppTextStyles.caption.copyWith(
                        color: ColorManager.primaryDark,
                      ),
                    ),
                    const SizedBox(width: AppSize.s4),
                    Transform.rotate(
                      angle: context.locale.languageCode == 'ar' ? 0 : math.pi,
                      child: const GroupAsset('cee4b.svg'),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSize.s12),
        child,
      ],
    ),
  );
}
