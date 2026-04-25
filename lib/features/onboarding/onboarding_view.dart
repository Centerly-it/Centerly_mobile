import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:centrally/core/res/color_manager.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 8.0),
                child: TextButton(
                  onPressed: () =>
                      GoRouter.of(context).pushReplacement("/login"),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "skip".tr(),
                        style: const TextStyle(
                          fontFamily: "cairo",
                          color: Color(0xff9E9E9E),
                          fontSize: 14,
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
                onPageChanged: (index) =>
                    setState(() => currentIndex = index),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.asset(
                            onboardingList[index].image,
                            height:
                                MediaQuery.of(context).size.height * 0.32,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          onboardingList[index].title.tr(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: "cairo",
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff1F1F1F),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          onboardingList[index].description.tr(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: "cairo",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff57595D),
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 40),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentIndex ==
                            onboardingList.length - 1) {
                          GoRouter.of(context)
                              .pushReplacement("/login");
                        } else {
                          _controller.nextPage(
                            duration:
                                const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            ColorManager.primary_blue,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        currentIndex ==
                                onboardingList.length - 1
                            ? "login".tr()
                            : "next".tr(),
                        style: const TextStyle(
                          fontFamily: "cairo",
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  if (currentIndex ==
                      onboardingList.length - 1) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton(
                        onPressed: () {
                          GoRouter.of(context)
                              .push("/register");
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color:
                                  ColorManager.primary_blue),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "register".tr(),
                          style: const TextStyle(
                            fontFamily: "cairo",
                            color:
                                ColorManager.primary_blue,
                            fontSize: 18,
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
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index
            ? ColorManager.primary_blue
            : const Color(0xffE3E7ED),
      ),
    );
  }
}