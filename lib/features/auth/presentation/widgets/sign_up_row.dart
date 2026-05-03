// ---------------------------------------------------------------------------
// Sign up row
// ---------------------------------------------------------------------------

import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUpRow extends StatelessWidget {
  const SignUpRow({super.key, required this.onTap});
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: '${StringsManager.loginNoAccount.tr()} ',
        style: AppTextStyles.labelLarge.copyWith(
          color: ColorManager.textSecondary,
        ),
        children: [
          TextSpan(
            text: StringsManager.loginCreateAccount.tr(),
            style: AppTextStyles.labelLarge.copyWith(
              color: ColorManager.primary,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}
