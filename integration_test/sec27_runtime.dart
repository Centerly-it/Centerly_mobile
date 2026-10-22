import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:centrally/main.dart' as app;
import 'package:centrally/core/di/di.dart';
import 'package:centrally/core/router/app_router.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:centrally/features/auth/presentation/widgets/submit_button.dart';
import 'package:centrally/screens/teacher/teacher_workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'runtime_accounts.dart';

const sec27Namespace = 'SEC27-ACCEPT-20261022';
Future<Map> sec27Registry() async =>
    jsonDecode(
          await File(
            Platform.environment['CENTERLY_SEC27_REGISTRY']!,
          ).readAsString(),
        )
        as Map;
Future<void> sec27Signal(String name, Map value) async {
  final path = Platform.environment['CENTERLY_SEC27_SIGNAL_DIR']!;
  await File('$path/$name.json').writeAsString(jsonEncode(value));
}

Future<void> sec27Loaded(WidgetTester tester, bool Function() ready) async {
  for (var i = 0; i < 120; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 250)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (ready()) {
      await tester.pump();
      return;
    }
  }
  fail('Hosted SEC27 UI did not become ready');
}

Future<NavigatorState> sec27Login(WidgetTester tester) async {
  await app.main();
  await tester.pumpAndSettle();
  AppRouter.router.go('/login');
  await tester.pumpAndSettle();
  if (getIt<AuthSessionCubit>().state.isAuthenticated) {
    await getIt<AuthSessionCubit>().logout();
    await tester.pumpAndSettle();
  }
  final a = await runtimeTeacherAccount();
  await sec27Loaded(
    tester,
    () => find.byType(TextFormField).evaluate().length == 2,
  );
  await tester.enterText(
    find.byType(TextFormField).at(0),
    a['email'] as String,
  );
  await tester.enterText(
    find.byType(TextFormField).at(1),
    a['password'] as String,
  );
  await tester.tap(find.byType(SubmitButton));
  await sec27Loaded(
    tester,
    () =>
        getIt<AuthSessionCubit>().state.isAuthenticated &&
        find.byType(TeacherWorkspace).evaluate().isNotEmpty,
  );
  expect(
    getIt<AuthSessionCubit>().state.profile!.teacherId,
    'f9f2e35a-2bed-437f-b3ee-28eb27b847c0',
  );
  return Navigator.of(tester.element(find.byType(TeacherWorkspace)));
}

Future<void> sec27Open(
  WidgetTester tester,
  NavigatorState root,
  Widget page,
  bool Function() ready,
) async {
  unawaited(root.push(MaterialPageRoute<void>(builder: (_) => page)));
  await tester.pump();
  await sec27Loaded(tester, ready);
}

Future<void> sec27Back(WidgetTester tester, NavigatorState root) async {
  root.pop();
  await tester.pumpAndSettle();
}
