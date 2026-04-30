import 'package:bloc/bloc.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/core/res/app_constants.dart';
import 'package:centrally/core/res/app_router.dart';
import 'package:centrally/core/res/strings_manager.dart';
import 'package:centrally/core/res/theme_manager.dart';
import 'package:centrally/core/utils/cached_data_shared_preferences.dart';
import 'package:centrally/core/utils/my_bloc_observer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Future.wait([
    CacheService.cacheInitialization(),
    EasyLocalization.ensureInitialized(),
  ]);

  configureDependencies();
  Bloc.observer = MyBlocObserver();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: AppConstants.translationsPath,
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ar'),
      child: const Centrally(),
    ),
  );
}

class Centrally extends StatelessWidget {
  const Centrally({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => StringsManager.appName.tr(),
      routerConfig: AppRouter.router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.light,
    );
  }
}
