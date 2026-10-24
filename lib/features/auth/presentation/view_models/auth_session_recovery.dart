import '../../domain/entities/teacher_profile.dart';
import 'auth_session_state.dart';

AuthSessionState restoreFailure(
  Object error, {
  required bool background,
  TeacherProfile? previous,
}) {
  final code = error is TeacherAuthFailure ? error.code : 'SERVICE_UNAVAILABLE';
  if (background &&
      previous != null &&
      {'NETWORK_ERROR', 'SERVICE_UNAVAILABLE', 'RATE_LIMITED'}.contains(code)) {
    return AuthSessionState(
      AuthSessionStatus.authenticated,
      profile: previous,
      errorCode: code,
    );
  }
  return AuthSessionState(AuthSessionStatus.signedOut, errorCode: code);
}
