import 'dart:async';
import 'features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/bootstrap_auth.dart';
import 'core/config/preview_mode.dart';
import 'core/localization/codegen_loader.g.dart';
import 'app/session_lifecycle.dart';

import 'package:bloc/bloc.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/core/constants/app_constants.dart';
import 'package:centrally/core/router/app_router.dart';
import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/theme_manager.dart';
import 'package:centrally/core/utils/cached_data_shared_preferences.dart';
import 'package:centrally/core/utils/my_bloc_observer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Future.wait([
    CacheService.cacheInitialization(),
    EasyLocalization.ensureInitialized(),
    initializeDateFormatting(),
  ]);

  configureDependencies();
  await bootstrapAuth(restoreSession: false);
  Bloc.observer = const MyBlocObserver();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
      assetLoader: const CodegenLoader(),
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ar'),
      child: const Centrally(),
    ),
  );
  // Release the native splash when Flutter is ready to render the app itself.
  FlutterNativeSplash.remove();
  // Paint first; the existing checking route gates access during remote validation.
  if (!PreviewMode.enabled) {
    widgetsBinding.addPostFrameCallback(
      (_) => unawaited(getIt<AuthSessionCubit>().restore()),
    );
  }
}

class Centrally extends StatelessWidget {
  const Centrally({super.key});
  @override
  Widget build(BuildContext context) => SessionLifecycle(
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      builder: (_, child) => PreviewMode.enabled
          ? Banner(
              message: 'ui_preview_mode'.tr(),
              location: BannerLocation.topEnd,
              child: child!,
            )
          : child!,
      onGenerateTitle: (context) => StringsManager.appName.tr(),
      routerConfig: AppRouter.router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.light,
    ),
  );
}
