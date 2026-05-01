// ---------------------------------------------------------------------------
// Submit button
// ---------------------------------------------------------------------------

import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.s54,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(
          StringsManager.loginSubmit.tr(),
          style: AppTextStyles.titleMedium.copyWith(color: ColorManager.white),
        ),
      ),
    );
  }
}
