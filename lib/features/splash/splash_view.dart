import 'package:centrally/core/res/assets_manager.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/routes_manager.dart';
import 'package:centrally/core/utils/cached_data_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1500)),
      _prefetchAppState(),
    ]);

    FlutterNativeSplash.remove();

    if (!mounted) return;

    final token = CacheService.getData(key: CacheConstants.userToken) as String?;
    if (token != null && token.isNotEmpty) {
      context.goNamed(RoutesManager.onboardingName); // replace with home once built
    } else {
      context.goNamed(RoutesManager.onboardingName);
    }
  }

  Future<void> _prefetchAppState() async {
    // Placeholder for remote config / feature flags / auth validation.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: Center(
        child: Image.asset(AssetsManager.logoAppIcon, width: 120),
      ),
    );
  }
}
