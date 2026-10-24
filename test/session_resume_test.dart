import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrally/app/session_lifecycle.dart';
import 'package:centrally/core/di/di.dart';
import 'package:centrally/core/utils/cached_data_shared_preferences.dart';
import 'package:centrally/screens/teacher/workspace_selection.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:centrally/features/auth/domain/entities/teacher_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/fake_teacher_auth.dart';

void main() {
  testWidgets(
    'resume validates quietly and restores only the owning account tab',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await CacheService.cacheInitialization();
      final repo = FakeAuth()..saved = profile;
      final cubit = AuthSessionCubit(repo);
      await cubit.restore();
      getIt.registerSingleton<AuthSessionCubit>(cubit);
      addTearDown(() async {
        await cubit.close();
        await repo.events.close();
        await getIt.reset();
      });
      await WorkspaceSelection.save(3);
      expect(WorkspaceSelection.restore(), 3);
      await tester.pumpWidget(
        const MaterialApp(
          home: SessionLifecycle(child: Text('retained draft')),
        ),
      );
      repo.pending = Completer<TeacherProfile?>();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(cubit.state.isAuthenticated, isTrue);
      expect(find.text('retained draft'), findsOneWidget);
      repo.pending!.complete(profile);
      await tester.pump();
      await cubit.logout();
      expect(WorkspaceSelection.restore(), 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
