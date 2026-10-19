import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/core/router/app_router.dart';
import 'package:centrally/core/utils/cached_data_shared_preferences.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:centrally/features/auth/presentation/views/login_view.dart';
import 'package:centrally/features/dashboard/data/dashboard_repository.dart';
import 'package:centrally/features/students/data/student_repository.dart';
import 'package:centrally/features/students/presentation/student_directory.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/dashboard_read_fixture.dart';
import 'helpers/fake_teacher_auth.dart';
import 'helpers/read_client_fixture.dart';
import 'helpers/student_read_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'logout removes a nested student directory and its contact data',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await CacheService.cacheInitialization();
      await EasyLocalization.ensureInitialized();
      final repo = FakeAuth()..saved = profile;
      final session = AuthSessionCubit(repo);
      await session.restore();
      final dashboard = (await tester.runAsync(
        () async => DashboardReadFixture().client(),
      ))!;
      final students = (await tester.runAsync(
        () async => readFixture(
          (request) async => jsonResponse(request, [studentJson('private')]),
        ),
      ))!;
      getIt.registerSingleton<AuthSessionCubit>(session);
      getIt.registerSingleton<DashboardRepository>(
        DashboardRepository(TeacherReadClient(dashboard)),
      );
      getIt.registerSingleton<StudentRepository>(
        StudentRepository(TeacherReadClient(students)),
      );
      final router = AppRouter.create(session, initialLocation: '/home');
      addTearDown(() async {
        router.dispose();
        await session.close();
        await repo.events.close();
        await tester.runAsync(() async {
          await getIt.reset();
          await dashboard.dispose();
          await students.dispose();
        });
      });
      await tester.runAsync(() async {
        await tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale('en')],
            startLocale: const Locale('en'),
            saveLocale: false,
            path: 'assets/translations',
            child: Builder(
              builder: (context) => MaterialApp.router(
                routerConfig: router,
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
              ),
            ),
          ),
        );
      });
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.school_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(StudentDirectory), findsOneWidget);
      expect(find.text('طالب تجريبي private'), findsOneWidget);
      await session.restore(background: true);
      await tester.pumpAndSettle();
      expect(find.byType(StudentDirectory), findsOneWidget);
      await session.logout();
      await tester.pumpAndSettle();
      expect(find.byType(LoginView), findsOneWidget);
      expect(find.byType(StudentDirectory), findsNothing);
      expect(find.text('طالب تجريبي private'), findsNothing);
    },
  );
}
