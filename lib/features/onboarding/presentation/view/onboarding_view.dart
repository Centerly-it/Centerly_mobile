import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/routes_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:centrally/features/onboarding/models/onboarding_model.dart';
import 'package:centrally/features/onboarding/presentation/widgets/skip_row.dart';
import 'package:centrally/features/onboarding/presentation/widgets/Dots_Indicator.dart';
import 'package:centrally/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:centrally/features/onboarding/presentation/widgets/onboarding_buttons.dart.dart';



class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == onboardingPages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goToLogin() => context.goNamed(RoutesManager.loginName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkipRow(visible: !_isLastPage, onSkip: _goToLogin),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: onboardingPages.length,
                itemBuilder: (_, i) =>OnboardingPage(model: onboardingPages[i])
              ),
            ),
            DotsIndicator(count: onboardingPages.length, current: _currentPage),
            const SizedBox(height: AppSize.s32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
              child: _isLastPage
                  ? OnboardingLastActions(onLogin: _goToLogin)
                  : OnboardingNextButton(onNext: _goToNextPage),
            ),
            const SizedBox(height: AppSize.s36),
          ],
        ),
      ),
    );
  }
}
