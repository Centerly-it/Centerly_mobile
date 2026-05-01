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
    try {
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 1500)),
        _prefetchAppState(),
      ]);
    } catch (_) {
      // Swallow prefetch errors — app must always navigate forward.
    } finally {
      FlutterNativeSplash.remove();
    }

    _navigate();
  }

  Future<void> _prefetchAppState() async {
    // TODO: Load remote config / feature flags / validate auth token.
  }

  void _navigate() {
    if (!mounted) return;

    final token =
        CacheService.getData(key: CacheConstants.userToken) as String?;
    final isAuthenticated = token != null && token.isNotEmpty;

    context.goNamed(
      isAuthenticated ? RoutesManager.homeName : RoutesManager.onboardingName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: Center(child: Image.asset(AssetsManager.logoAppIcon, width: 120)),
    );
  }
}
