import 'dart:async';
import 'package:centrally/features/auth/domain/entities/teacher_profile.dart';
import 'package:centrally/features/auth/domain/repo/teacher_auth_repository.dart';

const profile = TeacherProfile(
  id: '10000000-0000-0000-0000-000000000001',
  teacherId: '10000000-0000-0000-0000-000000000001',
);

class FakeAuth implements TeacherAuthRepository {
  final events = StreamController<void>.broadcast();
  TeacherProfile? saved;
  Object? failure;
  Completer<TeacherProfile?>? pending;
  Completer<TeacherProfile>? loginPending;
  int logouts = 0, logins = 0;
  @override
  Stream<void> get changes => events.stream;
  @override
  Future<TeacherProfile?> restore() async {
    if (failure != null) throw failure!;
    return pending != null ? pending!.future : saved;
  }

  @override
  Future<TeacherProfile> login(String email, String password) async {
    logins++;
    if (failure != null) throw failure!;
    return loginPending != null ? loginPending!.future : profile;
  }

  @override
  Future<void> logout() async {
    logouts++;
    saved = null;
  }
}
