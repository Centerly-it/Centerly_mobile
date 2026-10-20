import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/font_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';

class SessionSubpageBar extends StatelessWidget implements PreferredSizeWidget {
  const SessionSubpageBar({
    required this.title,
    this.readOnly = false,
    super.key,
  });
  final String title;
  final bool readOnly;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: SessionDesign.background,
    title: Text(
      title.tr(),
      style: AppTextStyles.headlineSmall.copyWith(
        fontWeight: FontWeightManager.bold,
      ),
    ),
    centerTitle: false,
    leading: IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => Navigator.of(context).pop(),
      icon: RotatedBox(
        quarterTurns: context.locale.languageCode == 'ar' ? 0 : 2,
        child: const SessionAsset('ea117.svg'),
      ),
    ),
    actions: [
      if (readOnly)
        Padding(
          padding: const EdgeInsets.all(AppPadding.p12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
            decoration: BoxDecoration(
              color: ColorManager.grey200,
              border: Border.all(color: SessionDesign.stroke),
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Center(
              child: Text(
                'design_read_only'.tr(),
                style: AppTextStyles.caption,
              ),
            ),
          ),
        ),
    ],
  );
}
