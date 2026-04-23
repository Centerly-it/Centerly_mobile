import 'package:bloc/bloc.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/core/res/app_router.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/utils/cached_data_shared_preferences.dart';
import 'package:centrally/core/utils/my_bloc_observer.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  await CacheService.cacheInitialization();
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  configureDependencies();
  Bloc.observer = MyBlocObserver();
  runApp(const Cnetrally());
}

class Cnetrally extends StatelessWidget {
  const Cnetrally({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: StringsManager.appName,
      routerConfig: AppRouter.router,
    );
  }
}
