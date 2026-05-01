import 'package:centrally/core/res/assets_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.illustration,
    required this.titleKey,
    required this.bodyKey,
  });

  final String illustration;
  final String titleKey;
  final String bodyKey;
}

 const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    illustration: AssetsManager.onboarding1,
    titleKey: StringsManager.onboarding1Title,
    bodyKey: StringsManager.onboarding1Body,
  ),
  OnboardingPageData(
    illustration: AssetsManager.onboarding2,
    titleKey: StringsManager.onboarding2Title,
    bodyKey: StringsManager.onboarding2Body,
  ),
  OnboardingPageData(
    illustration: AssetsManager.onboarding3,
    titleKey: StringsManager.onboarding3Title,
    bodyKey: StringsManager.onboarding3Body,
  ),
];