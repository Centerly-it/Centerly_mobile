import 'dart:async';
import 'teacher_read_endpoint.dart';
export 'teacher_read_endpoint.dart';
import 'dart:convert';
import '../network/read_cache.dart';
import '../network/read_coalescer.dart';
import 'teacher_read_policy.dart';
import 'teacher_read_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/backend_failure.dart';

class TeacherReadClient {
  TeacherReadClient(this.client, {this.onAccessDenied, ReadCache? cache})
    : cache = cache ?? ReadCache() {
    _identity = client.auth.currentUser?.id;
    _token = client.auth.currentSession?.accessToken;
  }
  final ReadCache cache;
  final _pending = ReadCoalescer();
  String? _identity, _token;
  void invalidate() {
    cache.clear();
    _pending.clear();
  }

  void _syncSession() {
    final id = client.auth.currentUser?.id,
        token = client.auth.currentSession?.accessToken;
    cache.bind((client.storage.url, id, token));
    if (id != _identity || token != _token) {
      invalidate();
      _identity = id;
      _token = token;
    }
  }

  final SupabaseClient client;
  final Future<void> Function()? onAccessDenied;
  void Function() sessionGuard() {
    _syncSession();
    final generation = cache.generation;
    final identity = client.auth.currentUser?.id;
    final token = client.auth.currentSession?.accessToken;
    return () {
      if (generation != cache.generation ||
          identity != client.auth.currentUser?.id ||
          token != client.auth.currentSession?.accessToken) {
        throw const BackendFailure('AUTH_REQUIRED');
      }
    };
  }

  Future<dynamic> read(
    TeacherRead endpoint, {
    Map<String, dynamic>? params,
    bool refresh = false,
  }) async {
    final checkSession = sessionGuard();
    params = snapshotReadParams(params);
    final identity = client.auth.currentUser?.id;
    final key = teacherReadKey(client.storage.url, identity, endpoint, params);
    final ttl = teacherReadTtl(endpoint);
    if (!refresh &&
        ttl > Duration.zero &&
        identity != null &&
        client.auth.currentSession?.isExpired == false) {
      final cached = cache.get(key);
      if (cached != null) {
        checkSession();
        return cached;
      }
    }
    final encoded = await _pending.run('${cache.generation}:$key', () async {
      final data = await fetchTeacherRead(
        client,
        endpoint,
        params,
        checkSession,
        () {
          invalidate();
          if (onAccessDenied != null) unawaited(onAccessDenied!());
        },
      );
      checkSession();
      final encoded = jsonEncode(data);
      if (identity != null && client.auth.currentSession?.isExpired == false) {
        cache.putEncoded(key, encoded, ttl: ttl);
      }
      return encoded;
    });
    checkSession();
    return jsonDecode(encoded);
  }
}
