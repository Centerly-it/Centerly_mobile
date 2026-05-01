import 'package:flutter/material.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class SkipRow extends StatelessWidget {
  const SkipRow({required this.visible, required this.onSkip});

  final bool visible;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.s48,
      child: Visibility(
        visible: visible,
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: onSkip,
            child: Text(
              StringsManager.onboardingSkip.tr(),
              style: AppTextStyles.labelLarge.copyWith(
                color: ColorManager.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
