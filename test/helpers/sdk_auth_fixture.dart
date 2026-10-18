import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const testTeacherId = '10000000-0000-0000-0000-000000000001';
SupabaseClient authFixture({
  String role = 'teacher',
  bool invalid = false,
  required List<String> requests,
}) {
  final payload = {
    'sub': testTeacherId,
    'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
  };
  final token =
      '${base64Url.encode(utf8.encode("{}"))}.${base64Url.encode(utf8.encode(jsonEncode(payload)))}.test';
  return SupabaseClient(
    'https://example.test',
    'sb_publishable_test',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
    httpClient: MockClient((request) async {
      requests.add(request.url.path);
      Object data = {};
      if (invalid) {
        data = {
          'code': 'invalid_credentials',
          'error_code': 'invalid_credentials',
          'msg': 'Invalid login credentials',
        };
      } else if (request.url.path.endsWith('/token')) {
        data = {
          'access_token': token,
          'refresh_token': 'synthetic-refresh-token',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': {
            'id': testTeacherId,
            'email': 'teacher@example.test',
            'app_metadata': {},
            'user_metadata': {},
            'created_at': '2026-01-01T00:00:00Z',
          },
        };
      } else if (request.url.path.endsWith('/get_current_profile')) {
        data = {'id': testTeacherId, 'teacher_id': testTeacherId, 'role': role};
      }
      return http.Response(
        jsonEncode(data),
        invalid ? 400 : 200,
        request: request,
        headers: {'content-type': 'application/json'},
      );
    }),
  );
}
