import '../../domain/entities/teacher_profile.dart';

enum AuthSessionStatus { checking, signedOut, authenticated }

class AuthSessionState {
  const AuthSessionState(this.status, {this.profile, this.errorCode});
  final AuthSessionStatus status;
  final TeacherProfile? profile;
  final String? errorCode;
  bool get isAuthenticated =>
      status == AuthSessionStatus.authenticated && profile != null;
}
