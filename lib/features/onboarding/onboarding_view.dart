import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:centrally/core/res/font_manager.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/routes_manager.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:centrally/features/onboarding/onboarding_model.dart'
    show onboardingList;

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextButton(
                  onPressed: () {
                    context.pushReplacement(RoutesManager.loginPath);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        StringsManager.skip.tr(),
                        style: const TextStyle(
                          fontFamily: "cairo",
                          color: ColorManager.grey500,
                          fontSize: FontSize.s14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Image.asset(
                        'assets/images/skip.png',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingList.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final item = onboardingList[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          item.image,
                          height: MediaQuery.of(context).size.height * 0.32,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            item.title.tr(),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: "cairo",
                              fontSize: FontSize.s24,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            item.description.tr(),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: "cairo",
                              fontSize: FontSize.s16,
                              fontWeight: FontWeight.w400,
                              color: ColorManager.textSecondary,
                              height: 1.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(
                            onboardingList.length,
                            (i) => buildDot(i),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentIndex == onboardingList.length - 1) {
                          context.pushReplacement(RoutesManager.loginPath);
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        currentIndex == onboardingList.length - 1
                            ? StringsManager.login.tr()
                            : StringsManager.next.tr(),
                        style: const TextStyle(
                          fontFamily: "cairo",
                          color: Colors.white,
                          fontSize: FontSize.s18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (currentIndex == onboardingList.length - 1) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton(
                        onPressed: () {
                          context.go(RoutesManager.registerPath);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: ColorManager.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          StringsManager.register.tr(),
                          style: const TextStyle(
                            fontFamily: "cairo",
                            color: ColorManager.primary,
                            fontSize: FontSize.s18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: currentIndex == index ? 22 : 8,
      margin: const EdgeInsetsDirectional.only(start: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index
            ? ColorManager.primary
            : ColorManager.grey300,
      ),
    );
  }
}