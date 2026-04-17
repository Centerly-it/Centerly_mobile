import 'package:centrally/splash_screen.dart';
import 'package:flutter/material.dart';

class RoutesManager {
  static const String splashRoute = '/';
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesManager.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('No Route Found')),
        body: const Center(child: Text('No Route Found')),
      ),
    );
  }
}
