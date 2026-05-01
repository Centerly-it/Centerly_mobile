import 'package:flutter/material.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:centrally/core/res/color_manager.dart' show ColorManager;


class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool outlined;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Text(
      text,
      style: AppTextStyles.titleMedium.copyWith(
        color: outlined
            ? ColorManager.primary
            : ColorManager.white,
      ),
    );

    return SizedBox(
      height: AppSize.s54,
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              child: child,
            )
          : FilledButton(
              onPressed: onPressed,
              child: child,
            ),
    );
  }
}
class OnboardingNextButton extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingNextButton({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: StringsManager.onboardingNext.tr(),
      onPressed: onNext,
    );
  }
}
class OnboardingLastActions extends StatelessWidget {
  final VoidCallback onLogin;

  const OnboardingLastActions({
    super.key,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          text: StringsManager.onboardingLogin.tr(),
          onPressed: onLogin,
        ),

        const SizedBox(height: AppSize.s12),

        AppButton(
          text: StringsManager.onboardingSignup.tr(),
          onPressed: onLogin,
          outlined: true,
        ),
      ],
    );
  }
}