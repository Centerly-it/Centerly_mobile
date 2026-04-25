class OnboardingModel {
  final String image;
  final String title;
  final String description;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.description,
  });
}
List<OnboardingModel> onboardingList = [
  OnboardingModel(
    image: "assets/images/onboarding4.png",
    title: "onboarding_title_1",
    description: "onboarding_desc_1",
  ),
  OnboardingModel(
    image: "assets/images/onboarding5.png",
    title: "onboarding_title_2",
    description: "onboarding_desc_2",
  ),
  OnboardingModel(
    image: "assets/images/onboarding6.png",
    title: "onboarding_title_3",
    description: "onboarding_desc_3",
  ),
];