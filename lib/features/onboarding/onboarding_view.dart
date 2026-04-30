import 'package:centrally/core/res/assets_manager.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/routes_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:centrally/core/res/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.illustration,
    required this.titleKey,
    required this.bodyKey,
  });

  final String illustration;
  final String titleKey;
  final String bodyKey;
}

const List<_OnboardingPageData> _pages = [
  _OnboardingPageData(
    illustration: AssetsManager.onboarding1,
    titleKey: StringsManager.onboarding1Title,
    bodyKey: StringsManager.onboarding1Body,
  ),
  _OnboardingPageData(
    illustration: AssetsManager.onboarding2,
    titleKey: StringsManager.onboarding2Title,
    bodyKey: StringsManager.onboarding2Body,
  ),
  _OnboardingPageData(
    illustration: AssetsManager.onboarding3,
    titleKey: StringsManager.onboarding3Title,
    bodyKey: StringsManager.onboarding3Body,
  ),
];

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == _pages.length - 1;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SkipRow(visible: !_isLastPage, onSkip: _goToLogin),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
              ),
            ),
            _DotsIndicator(count: _pages.length, current: _currentPage),
            const SizedBox(height: AppSize.s32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
              child: _isLastPage
                  ? _LastPageActions(onLogin: _goToLogin)
                  : _NextButton(onNext: _goToNextPage),
            ),
            const SizedBox(height: AppSize.s36),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skip row
// ---------------------------------------------------------------------------

class _SkipRow extends StatelessWidget {
  const _SkipRow({required this.visible, required this.onSkip});

  final bool visible;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.s48,
      child: Visibility(
        visible: visible,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
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

// ---------------------------------------------------------------------------
// Single onboarding page
// ---------------------------------------------------------------------------

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _IllustrationCard(asset: data.illustration)),
          const SizedBox(height: AppSize.s32),
          Text(
            data.titleKey.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge,
          ),
          const SizedBox(height: AppSize.s12),
          Text(
            data.bodyKey.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: ColorManager.textSecondary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: AppSize.s24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Illustration card
// ---------------------------------------------------------------------------

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSize.s24),
      child: Container(
        color: ColorManager.background,
        padding: const EdgeInsets.all(AppPadding.p24),
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, _) => const _IllustrationPlaceholder(),
        ),
      ),
    );
  }
}

class _IllustrationPlaceholder extends StatelessWidget {
  const _IllustrationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        size: AppSize.s100,
        color: ColorManager.grey300,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dot indicator
// ---------------------------------------------------------------------------

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: AppSize.s5),
          width: isActive ? AppSize.s24 : AppSize.s8,
          height: AppSize.s8,
          decoration: BoxDecoration(
            color: isActive ? ColorManager.primary : ColorManager.grey300,
            borderRadius: BorderRadius.circular(AppSize.s8),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.s54,
      child: FilledButton(
        onPressed: onNext,
        child: Text(
          StringsManager.onboardingNext.tr(),
          style: AppTextStyles.titleMedium.copyWith(color: ColorManager.white),
        ),
      ),
    );
  }
}

class _LastPageActions extends StatelessWidget {
  const _LastPageActions({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: AppSize.s54,
          child: FilledButton(
            onPressed: onLogin,
            child: Text(
              StringsManager.onboardingLogin.tr(),
              style: AppTextStyles.titleMedium.copyWith(color: ColorManager.white),
            ),
          ),
        ),
        const SizedBox(height: AppSize.s12),
        SizedBox(
          height: AppSize.s54,
          child: OutlinedButton(
            onPressed: onLogin,
            child: Text(
              StringsManager.onboardingSignup.tr(),
              style: AppTextStyles.titleMedium.copyWith(color: ColorManager.primary),
            ),
          ),
        ),
      ],
    );
  }
}
