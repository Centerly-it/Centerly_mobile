import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient readFixture(
  Future<http.Response> Function(http.Request) handler,
) => SupabaseClient(
  'https://example.test',
  'sb_publishable_test',
  authOptions: const AuthClientOptions(autoRefreshToken: false),
  httpClient: MockClient(handler),
);
http.Response jsonResponse(
  http.Request request,
  Object? data, {
  int status = 200,
}) => http.Response(
  jsonEncode(data),
  status,
  request: request,
  headers: {'content-type': 'application/json'},
);
