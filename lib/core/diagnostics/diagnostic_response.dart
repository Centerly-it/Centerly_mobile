import 'dart:convert';

const diagnosticErrorCodes = {
  'AUTH_REQUIRED',
  'ACCOUNT_INACTIVE',
  'SUBSCRIPTION_INACTIVE',
  'FORBIDDEN_ROLE',
  'TENANT_SCOPE',
  'VALIDATION_ERROR',
  'NOT_FOUND',
  'CONFLICT',
  'ALREADY_CANCELLED',
  'RATE_LIMITED',
  'P0001',
  '42501',
  '23505',
  '23503',
  '23514',
  'PGRST202',
  'PGRST301',
  'PGRST302',
  'PGRST303',
  'invalid_credentials',
  'refresh_token_not_found',
  'user_banned',
};

({String shape, String? code}) diagnosticResponse(List<int> prefix, int bytes) {
  if (prefix.length != bytes) {
    return (shape: 'body_over_preview_limit', code: null);
  }
  try {
    final body = jsonDecode(utf8.decode(prefix));
    if (body is Map) {
      final candidates = [
        body['message'],
        body['error_code'],
        body['code'],
        body['error'],
      ];
      final code = candidates
          .whereType<String>()
          .where(diagnosticErrorCodes.contains)
          .firstOrNull;
      return (shape: 'object:${body.length}_keys', code: code);
    }
    if (body is List) return (shape: 'array:${body.length}_items', code: null);
    return (shape: 'scalar', code: null);
  } catch (_) {
    return (shape: bytes == 0 ? 'empty' : 'non_json', code: null);
  }
}
