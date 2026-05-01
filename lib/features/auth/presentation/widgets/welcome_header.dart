// ---------------------------------------------------------------------------
// Welcome header
// ---------------------------------------------------------------------------

import 'package:centrally/core/func/extensions.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringsManager.loginWelcomeTitle.tr(),
          style: AppTextStyles.headlineMedium,
        ),
        SizedBox(height: context.screenHeight * 0.008), // AppSize.s6
        Text(
          StringsManager.loginWelcomeSubtitle.tr(),
          textAlign: TextAlign.start,
          style: AppTextStyles.bodyMedium.copyWith(
            color: ColorManager.textSecondary,
          ),
        ),
      ],
    );
  }
}
