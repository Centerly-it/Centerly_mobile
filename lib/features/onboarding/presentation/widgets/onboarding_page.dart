import 'package:flutter/material.dart';
import '../../models/onboarding_model.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData model;

  const OnboardingPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSize.s16),

          Expanded(
            child: Center(
              child: Image.asset(model.illustration, fit: BoxFit.contain),
            ),
          ),

          const SizedBox(height: AppSize.s16),

          Text(model.titleKey.tr(), style: AppTextStyles.headlineLarge),

          const SizedBox(height: AppSize.s12),

          Text(
            model.bodyKey.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: ColorManager.textSecondary,
            ),
          ),

          const SizedBox(height: AppSize.s24),
        ],
      ),
    );
  }
}
