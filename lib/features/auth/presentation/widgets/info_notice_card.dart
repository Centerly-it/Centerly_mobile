import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class InfoNoticeCard extends StatelessWidget {
  const InfoNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
        side: const BorderSide(color: ColorManager.primaryLight, width: 0.5),
      ),
      margin: EdgeInsets.zero,
      elevation: 0,
      color: ColorManager.primaryBright,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p14),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p8),
              child: Icon(
                Icons.error_outline_rounded,
                size: AppSize.s18,
                color: ColorManager.primaryDark,
              ),
            ),
            Text(
              StringsManager.noticeInfo.tr(),
              style: AppTextStyles.bodySmall.copyWith(
                color: ColorManager.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
