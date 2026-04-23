import 'package:centrally/core/res/routes_manager.dart';
import 'package:centrally/features/auth/presentation/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RoutesManager.loginPath,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('No Router Found')),
      body: const Center(child: Text('No Router Found')),
    ),
    routes: [
      GoRoute(
        path: RoutesManager.loginPath,
        name: RoutesManager.loginName,
        builder: (context, state) => const LoginView(),
      ),
    ],
  );
}
