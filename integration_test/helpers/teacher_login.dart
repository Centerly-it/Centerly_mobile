import 'package:centrally/main.dart' as app;
import 'package:centrally/core/di/di.dart';
import 'package:centrally/core/router/app_router.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:centrally/features/auth/presentation/widgets/submit_button.dart';
import 'package:centrally/core/widgets/app_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> teacherLogin(WidgetTester tester) async {
  await app.main();
  await tester.pumpAndSettle();
  if (getIt<AuthSessionCubit>().state.isAuthenticated) {
    await getIt<AuthSessionCubit>().logout();
    await tester.pumpAndSettle();
  }
  AppRouter.router.go('/login');
  await tester.pumpAndSettle();
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
    i < 100 && !getIt<AuthSessionCubit>().state.isAuthenticated;
    i++
  ) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(getIt<AuthSessionCubit>().state.isAuthenticated, isTrue);
  await settleLive(tester);
}

Future<void> settleLive(WidgetTester tester) async {
  // Real network needs wall-clock progress; bounded loop avoids endless spinners.
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 200));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty &&
        find.byType(LinearProgressIndicator).evaluate().isEmpty) {
      break;
    }
  }
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 20),
  );
  expect(find.byType(AppErrorState), findsNothing);
  expect(tester.takeException(), isNull);
}
