import 'package:flutter/material.dart';
import '../../../auth/presentation/widgets/contact_support_button.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/core/constants/strings_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/app_button.dart';
export '../../../../core/widgets/app_button.dart';

class OnboardingNextButton extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingNextButton({super.key, required this.onNext});

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

  const OnboardingLastActions({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          text: StringsManager.onboardingLogin.tr(),
          onPressed: onLogin,
        ),

        const SizedBox(height: AppSize.s12),

        const ContactSupportButton(outlined: true),
      ],
    );
  }
}
