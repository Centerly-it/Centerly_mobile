import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sdk_auth_fixture.dart';
import 'read_client_fixture.dart';

SupabaseClient scopedReadFixture(
  Future<http.Response> Function(http.Request) rpc, {
  String project = 'https://example.test',
}) {
  var version = 0;
  return SupabaseClient(
    project,
    'sb_publishable_test',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
    httpClient: MockClient((request) async {
      if (request.url.path.endsWith('/token')) {
        final payload = {
          'sub': testTeacherId,
          'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
          'version': ++version,
        };
        final token =
            '${base64Url.encode(utf8.encode('{}'))}.${base64Url.encode(utf8.encode(jsonEncode(payload)))}.test';
        return jsonResponse(request, {
          'access_token': token,
          'refresh_token': 'synthetic-refresh',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': {
            'id': testTeacherId,
            'app_metadata': {},
            'user_metadata': {},
            'created_at': '2026-01-01T00:00:00Z',
          },
        });
      }
      if (request.url.path.endsWith('/logout')) {
        return jsonResponse(request, {});
      }
      return rpc(request);
    }),
  );
}

Future<void> signInReadFixture(SupabaseClient client) => client.auth
    .signInWithPassword(
      email: 'synthetic@example.test',
      password: 'local-fixture-only',
    )
    .then((_) {});
