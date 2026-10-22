import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/account_check_view.dart';
import '../../features/auth/presentation/view_models/auth_session_cubit.dart';
import '../../features/auth/presentation/view_models/auth_session_state.dart';
import '../../features/onboarding/presentation/view/onboarding_view.dart';
import '../../screens/teacher/teacher_workspace.dart';
import '../di/di.dart';
import 'routes_manager.dart';
import 'session_router_refresh.dart';

class AppRouter {
  AppRouter._();
  static GoRouter create(
    AuthSessionCubit session, {
    String initialLocation = RoutesManager.onboardingPath,
  }) => GoRouter(
    initialLocation: initialLocation,
    refreshListenable: SessionRouterRefresh(session),
    redirect: (_, state) {
      final status = session.state;
      if (status.status == AuthSessionStatus.checking) return '/checking';
      if (status.isAuthenticated) {
        return state.matchedLocation == RoutesManager.homePath
            ? null
            : RoutesManager.homePath;
      }
      if (state.matchedLocation == '/') return RoutesManager.onboardingPath;
      if ([
        RoutesManager.loginPath,
        RoutesManager.onboardingPath,
      ].contains(state.matchedLocation)) {
        return null;
      }
      return RoutesManager.loginPath;
    },
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('route_not_found'.tr()))),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => RoutesManager.onboardingPath),
      GoRoute(
        path: '/checking',
        builder: (_, state) => const AccountCheckView(),
      ),
      GoRoute(
        path: RoutesManager.onboardingPath,
        name: RoutesManager.onboardingName,
        builder: (_, state) => const OnboardingView(),
      ),
      GoRoute(
        path: RoutesManager.loginPath,
        name: RoutesManager.loginName,
        builder: (_, state) => const LoginView(),
      ),
      GoRoute(
        path: RoutesManager.homePath,
        name: RoutesManager.homeName,
        builder: (_, state) => const TeacherWorkspace(),
      ),
    ],
  );
  static final GoRouter router = create(getIt<AuthSessionCubit>());
}
