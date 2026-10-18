import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/teacher_profile.dart';

TeacherAuthFailure mapAuthFailure(Object error) {
  if (error is TeacherAuthFailure) return error;
  if (error is PostgrestException) {
    const codes = {
      'AUTH_REQUIRED',
      'ACCOUNT_INACTIVE',
      'SUBSCRIPTION_INACTIVE',
      'FORBIDDEN_ROLE',
      'TENANT_SCOPE',
    };
    return TeacherAuthFailure(
      codes.contains(error.message) ? error.message : 'SERVICE_UNAVAILABLE',
    );
  }
  if (error is AuthException) {
    if (error.statusCode == '429') {
      return const TeacherAuthFailure('RATE_LIMITED');
    }
    if (error.code == 'invalid_credentials') {
      return const TeacherAuthFailure('INVALID_CREDENTIALS');
    }
    if (error is AuthRetryableFetchException) {
      return const TeacherAuthFailure('NETWORK_ERROR');
    }
    return const TeacherAuthFailure('AUTH_REQUIRED');
  }
  return const TeacherAuthFailure('NETWORK_ERROR');
}
