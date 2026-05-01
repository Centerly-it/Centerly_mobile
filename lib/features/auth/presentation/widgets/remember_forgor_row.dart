// ---------------------------------------------------------------------------
// Remember me + forgot password row
// ---------------------------------------------------------------------------

import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RememberForgotRow extends StatelessWidget {
  const RememberForgotRow({
    required this.rememberMe,
    required this.onRememberChanged,
    super.key,
  });

  final bool rememberMe;
  final ValueChanged<bool?> onRememberChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            StringsManager.loginForgotPassword.tr(),
            style: AppTextStyles.labelSmall.copyWith(
              color: ColorManager.primary,
            ),
          ),
        ),
        Row(
          children: [
            Text(
              StringsManager.loginRememberMe.tr(),
              style: AppTextStyles.labelSmall,
            ),
            const SizedBox(width: AppSize.s8),
            SizedBox(
              width: AppSize.s20,
              height: AppSize.s20,
              child: Checkbox(
                value: rememberMe,
                onChanged: onRememberChanged,
                activeColor: ColorManager.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.s5),
                ),
                side: const BorderSide(color: ColorManager.border),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
