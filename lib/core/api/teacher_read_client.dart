import 'dart:async';
import 'dart:convert';
import '../network/read_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/backend_failure.dart';

enum TeacherRead {
  dashboard,
  students,
  sessions,
  groups,
  overview,
  namedSessions,
}

class TeacherReadClient {
  TeacherReadClient(this.client, {this.onAccessDenied, ReadCache? cache})
    : cache = cache ?? ReadCache();
  final ReadCache cache;
  void invalidate() => cache.clear();
  final SupabaseClient client;
  final Future<void> Function()? onAccessDenied;
  static const _names = {
    TeacherRead.dashboard: 'get_teacher_dashboard',
    TeacherRead.students: 'list_students',
    TeacherRead.sessions: 'list_sessions',
    TeacherRead.groups: 'list_teacher_groups',
    TeacherRead.overview: 'get_teacher_overview',
    TeacherRead.namedSessions: 'list_teacher_sessions',
  };
  Future<dynamic> read(
    TeacherRead endpoint, {
    Map<String, dynamic>? params,
    bool refresh = false,
  }) async {
    final generation = cache.generation;
    final identity = client.auth.currentUser?.id;
    final token = client.auth.currentSession?.accessToken;
    final key = jsonEncode([identity, endpoint.name, params]);
    void checkSession() {
      if (generation != cache.generation ||
          identity != client.auth.currentUser?.id ||
          token != client.auth.currentSession?.accessToken) {
        throw const BackendFailure('AUTH_REQUIRED');
      }
    }

    if (!refresh &&
        identity != null &&
        client.auth.currentSession?.isExpired == false) {
      final cached = cache.get(key);
      if (cached != null) return cached;
    }
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final data = await client
            .rpc(_names[endpoint]!, params: params)
            .timeout(const Duration(seconds: 15));
        checkSession();
        if (identity != null) cache.put(key, data);
        return data;
      } catch (error) {
        checkSession();
        final failure = mapBackendFailure(error);
        if (failure.deniesAccess) {
          invalidate();
          if (onAccessDenied != null) unawaited(onAccessDenied!());
          throw failure;
        }
        if (failure.code != 'NETWORK_ERROR' || attempt == 1) throw failure;
      }
    }
    throw const BackendFailure('SERVICE_UNAVAILABLE');
  }
}
