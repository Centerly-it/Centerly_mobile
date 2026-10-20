import 'dart:async';
import 'package:centrally/features/auth/domain/entities/teacher_profile.dart';
import 'helpers/fake_teacher_auth.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_cubit.dart';
import 'package:centrally/features/auth/presentation/view_models/auth_session_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAuth repo;
  late AuthSessionCubit cubit;
  setUp(() {
    repo = FakeAuth();
    cubit = AuthSessionCubit(repo);
  });
  tearDown(() async {
    await cubit.close();
    await repo.events.close();
  });
  test('restored sessions require a fresh server profile', () async {
    await cubit.restore();
    expect(cubit.state.isAuthenticated, isFalse);
    repo.saved = profile;
    await cubit.restore();
    expect(cubit.state.profile?.teacherId, profile.teacherId);
  });
  test('login errors remain signed out and never expose raw errors', () async {
    repo.failure = const TeacherAuthFailure('INVALID_CREDENTIALS');
    await cubit.login('teacher@example.test', 'unchanged password');
    expect(cubit.state.isAuthenticated, isFalse);
    expect(cubit.state.errorCode, 'INVALID_CREDENTIALS');
  });
  test(
    'deactivation and offline revalidation hide protected screens',
    () async {
      repo.saved = profile;
      await cubit.restore();
      repo.failure = const TeacherAuthFailure('ACCOUNT_INACTIVE');
      await cubit.restore();
      expect(cubit.state.profile, isNull);
      expect(cubit.state.errorCode, 'ACCOUNT_INACTIVE');
      repo.failure = const TeacherAuthFailure('NETWORK_ERROR');
      await cubit.restore();
      expect(cubit.state.status, AuthSessionStatus.signedOut);
    },
  );
  test('logout wins over an in-flight restore', () async {
    repo.pending = Completer<TeacherProfile?>();
    final restore = cubit.restore();
    await cubit.logout();
    repo.pending!.complete(profile);
    await restore;
    expect(cubit.state.isAuthenticated, isFalse);
    expect(repo.logouts, 1);
  });
  test('old restore cannot release the busy flag of a newer logout', () async {
    repo.pending = Completer<TeacherProfile?>();
    repo.logoutPending = Completer<void>();
    final restore = cubit.restore();
    final logout = cubit.logout();
    repo.pending!.complete(profile);
    await restore;
    await cubit.login('new', 'login');
    expect(repo.logins, 0);
    expect(cubit.state.isAuthenticated, false);
    repo.logoutPending!.complete();
    await logout;
    await cubit.login('new', 'login');
    expect(repo.logins, 1);
    expect(cubit.state.isAuthenticated, true);
  });
  test('duplicate login taps invoke repository once', () async {
    repo.loginPending = Completer<TeacherProfile>();
    final first = cubit.login('a', 'b');
    await cubit.login('a', 'b');
    expect(repo.logins, 1);
    repo.loginPending!.complete(profile);
    await first;
    expect(cubit.state.isAuthenticated, isTrue);
  });
  test('logout wins over an in-flight login result', () async {
    repo.loginPending = Completer<TeacherProfile>();
    final login = cubit.login('a', 'b');
    await cubit.logout();
    repo.loginPending!.complete(profile);
    await login;
    expect(cubit.state.isAuthenticated, isFalse);
  });
  test(
    'periodic validation preserves authenticated UI but deactivation fails closed',
    () async {
      repo.saved = profile;
      await cubit.restore();
      repo.pending = Completer<TeacherProfile?>();
      final validation = cubit.restore(background: true);
      expect(cubit.state.isAuthenticated, isTrue);
      repo.pending!.complete(profile);
      await validation;
      repo.failure = const TeacherAuthFailure('ACCOUNT_INACTIVE');
      await cubit.restore(background: true);
      expect(cubit.state.isAuthenticated, isFalse);
      expect(cubit.state.errorCode, 'ACCOUNT_INACTIVE');
    },
  );
}
