// ---------------------------------------------------------------------------
// Sign up row
// ---------------------------------------------------------------------------

import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SignUpRow extends StatelessWidget {
  const SignUpRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            StringsManager.loginCreateAccount.tr(),
            style: AppTextStyles.labelLarge.copyWith(
              color: ColorManager.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSize.s5),
        Text(
          StringsManager.loginNoAccount.tr(),
          style: AppTextStyles.labelLarge.copyWith(
            color: ColorManager.textSecondary,
          ),
        ),
      ],
    );
  }
}
