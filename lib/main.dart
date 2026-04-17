import 'package:bloc/bloc.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/core/res/routes_manager.dart';
import 'package:centrally/core/utils/cached_data_shared_preferences.dart';
import 'package:centrally/core/utils/my_bloc_observer.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService.cacheInitialization();
  configureDependencies();
  Bloc.observer = MyBlocObserver();
  runApp(const Cnetrally());
}

class Cnetrally extends StatelessWidget {
  const Cnetrally({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cnetrally',
      onGenerateRoute: RouteGenerator.getRoute,
      initialRoute: RoutesManager.splashRoute,
    );
  }
}
