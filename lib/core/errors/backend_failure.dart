import 'dart:async';
import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackendFailure implements Exception {
  const BackendFailure(this.code);
  final String code;
  bool get deniesAccess => {
    'AUTH_REQUIRED',
    'ACCOUNT_INACTIVE',
    'SUBSCRIPTION_INACTIVE',
    'FORBIDDEN_ROLE',
    'TENANT_SCOPE',
  }.contains(code);
  @override
  String toString() => code;
}

BackendFailure mapBackendFailure(Object error) {
  if (error is BackendFailure) return error;
  if (error is TimeoutException ||
      error is ClientException ||
      error is AuthRetryableFetchException) {
    return const BackendFailure('NETWORK_ERROR');
  }
  if (error is AuthException) return const BackendFailure('AUTH_REQUIRED');
  if (error is PostgrestException) {
    const business = {
      'AUTH_REQUIRED',
      'ACCOUNT_INACTIVE',
      'SUBSCRIPTION_INACTIVE',
      'FORBIDDEN_ROLE',
      'TENANT_SCOPE',
      'VALIDATION_ERROR',
      'NOT_FOUND',
      'CONFLICT',
      'ALREADY_CANCELLED',
      'ATTENDANCE_CORRECTION_REASON_REQUIRED',
      'RATE_LIMITED',
    };
    if (business.contains(error.message)) return BackendFailure(error.message);
    if ({'PGRST301', 'PGRST302', 'PGRST303'}.contains(error.code)) {
      return const BackendFailure('AUTH_REQUIRED');
    }
  }
  return const BackendFailure('SERVICE_UNAVAILABLE');
}
