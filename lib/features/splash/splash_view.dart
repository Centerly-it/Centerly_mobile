import 'dart:developer';

import 'package:centrally/core/constants/app_constants.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/router/routes_manager.dart';
import 'package:centrally/core/widgets/brand_logo.dart';
import '../../core/theme/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Keep the system splash until Flutter has painted its first branded frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FlutterNativeSplash.remove();
    });
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Future.wait([
        Future.delayed(const Duration(milliseconds: AppConstants.splashDelay)),
        _prefetchAppState(),
      ]);
    } catch (error, stackTrace) {
      log('Error during Splash prefetch', error: error, stackTrace: stackTrace);
      await Sentry.captureException(error, stackTrace: stackTrace);
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

    context.goNamed(RoutesManager.onboardingName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: Center(
        child: BrandLogo(
          size: (MediaQuery.sizeOf(context).width * 0.55).clamp(
            AppSize.s200,
            AppSize.s240,
          ),
        ),
      ),
    );
  }
}
