import 'package:centrally/main.dart' as app;
import 'package:centrally/core/auth/secure_auth_storage.dart';
import 'package:centrally/core/config/app_config.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/core/router/app_router.dart';
import 'package:centrally/features/auth/presentation/views/login_view.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:centrally/features/auth/presentation/widgets/submit_button.dart';
import 'package:centrally/screens/teacher/teacher_workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native hosted login persists securely and logout removes session',
    (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      AppRouter.router.go('/login');
      await tester.pumpAndSettle();
      if (find.byType(TeacherWorkspace).evaluate().isNotEmpty) {
        await getIt<AuthSessionCubit>().logout();
        await tester.pumpAndSettle();
      }
      expect(find.byType(LoginView), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        const String.fromEnvironment('TEST_TEACHER_EMAIL'),
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        const String.fromEnvironment('TEST_TEACHER_PASSWORD'),
      );
      await tester.ensureVisible(find.byType(SubmitButton));
      await tester.tap(find.byType(SubmitButton));
      for (
        var i = 0;
        i < 80 && !getIt<AuthSessionCubit>().state.isAuthenticated;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      expect(getIt<AuthSessionCubit>().state.isAuthenticated, isTrue);
      await tester.pumpAndSettle();
      expect(find.byType(TeacherWorkspace), findsOneWidget);
      final config = getIt<AppConfig>();
      final storage = SecureAuthStorage(
        'centerly-${Uri.parse(config.url).host}-session',
      );
      expect(await storage.hasAccessToken(), isTrue);
      expect(await storage.accessToken(), isNotEmpty);
      await getIt<AuthSessionCubit>().restore();
      await tester.pumpAndSettle();
      expect(find.byType(TeacherWorkspace), findsOneWidget);
      await tester.tap(find.byIcon(Icons.logout));
      for (var i = 0; i < 40 && await storage.hasAccessToken(); i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      await tester.pumpAndSettle();
      expect(find.byType(LoginView), findsOneWidget);
      expect(await storage.hasAccessToken(), isFalse);
    },
  );
}
