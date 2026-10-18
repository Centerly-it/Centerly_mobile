import '../entities/teacher_profile.dart';

abstract interface class TeacherAuthRepository {
  Stream<void> get changes;
  Future<TeacherProfile?> restore();
  Future<TeacherProfile> login(String email, String password);
  Future<void> logout();
}

class UnconfiguredTeacherAuth implements TeacherAuthRepository {
  const UnconfiguredTeacherAuth();
  @override
  Stream<void> get changes => const Stream.empty();
  @override
  Future<TeacherProfile?> restore() async => null;
  @override
  Future<TeacherProfile> login(String email, String password) async =>
      throw const TeacherAuthFailure('NOT_CONFIGURED');
  @override
  Future<void> logout() async {}
}
