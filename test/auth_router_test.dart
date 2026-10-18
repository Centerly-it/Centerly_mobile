import 'package:centrally/core/di/di.dart';
import 'package:centrally/core/router/app_router.dart';
import 'package:centrally/core/theme/theme_manager.dart';
import 'package:centrally/core/utils/cached_data_shared_preferences.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:centrally/features/auth/presentation/views/login_view.dart';
import 'package:centrally/features/auth/presentation/views/create_admin_view.dart';
import 'package:centrally/features/auth/presentation/views/create_center_view.dart';
import 'package:centrally/screens/teacher/teacher_workspace.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/fake_teacher_auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });
  for (final path in [
    '/home?role=secretary',
    '/create_admin',
    '/create_center',
  ]) {
    testWidgets('unauthenticated $path cannot bypass live profile validation', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'userToken': 'fake-dev-token',
        'role': 'secretary',
      });
      await CacheService.cacheInitialization();
      final repo = FakeAuth();
      final session = AuthSessionCubit(repo);
      await session.restore();
      getIt.registerSingleton<AuthSessionCubit>(session);
      final router = AppRouter.create(session, initialLocation: path);
      addTearDown(() async {
        router.dispose();
        await session.close();
        await repo.events.close();
        await getIt.reset();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('ar'), Locale('en')],
          path: 'assets/translations',
          startLocale: const Locale('en'),
          saveLocale: false,
          child: _RouterApp(router),
        ),
      );
      await tester.pumpAndSettle();
      if (path.startsWith('/home')) {
        expect(find.byType(LoginView), findsOneWidget);
        expect(router.routeInformationProvider.value.uri.path, '/login');
      } else {
        expect(find.byType(CreateAdminView), findsNothing);
        expect(find.byType(CreateCenterView), findsNothing);
        expect(find.byType(TeacherWorkspace), findsNothing);
      }
      expect(find.byType(SegmentedButton<dynamic>), findsNothing);
    });
  }
}

class _RouterApp extends StatelessWidget {
  const _RouterApp(this.router);
  final GoRouter router;
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.light,
    locale: context.locale,
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
  );
}
