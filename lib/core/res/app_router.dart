import 'package:centrally/core/res/routes_manager.dart';
import 'package:centrally/core/utils/cached_data_shared_preferences.dart';
import 'package:centrally/features/auth/presentation/views/login_view.dart';
import 'package:centrally/features/onboarding/onboarding_view.dart';
import 'package:centrally/features/splash/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:centrally/core/res/routes_manager.dart';
import 'package:centrally/features/onboarding/onboarding_view.dart';
import 'package:centrally/features/auth/presentation/views/login_view.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RoutesManager.splashPath,
    redirect: _authRedirect,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('No route defined for ${state.uri.path}'),
      ),
    ),
    routes: [
      GoRoute(
        path: RoutesManager.splashPath,
        name: RoutesManager.splashName,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: RoutesManager.onboardingPath,
        name: RoutesManager.onboardingName,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: RoutesManager.loginPath,
        name: RoutesManager.loginName,
        builder: (context, state) => const LoginView(),
      ),
    ],
  );

  static String? _authRedirect(BuildContext context, GoRouterState state) {
    final token = CacheService.getData(key: CacheConstants.userToken) as String?;
    final isAuthenticated = token != null && token.isNotEmpty;
    final isSplash = state.matchedLocation == RoutesManager.splashPath;

    if (isSplash) return null;

    const publicRoutes = [
      RoutesManager.onboardingPath,
      RoutesManager.loginPath,
    ];

    if (!isAuthenticated && !publicRoutes.contains(state.matchedLocation)) {
      return RoutesManager.loginPath;
    }

    return null;
  }
}