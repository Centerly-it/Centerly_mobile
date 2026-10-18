import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/backend_failure.dart';

enum TeacherRead { dashboard, students, sessions }

class TeacherReadClient {
  TeacherReadClient(this.client, {this.onAccessDenied});
  final SupabaseClient client;
  final Future<void> Function()? onAccessDenied;
  static const _names = {
    TeacherRead.dashboard: 'get_teacher_dashboard',
    TeacherRead.students: 'list_students',
    TeacherRead.sessions: 'list_sessions',
  };
  Future<dynamic> read(
    TeacherRead endpoint, {
    Map<String, dynamic>? params,
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await client
            .rpc(_names[endpoint]!, params: params)
            .timeout(const Duration(seconds: 15));
      } catch (error) {
        final failure = mapBackendFailure(error);
        if (failure.deniesAccess) {
          if (onAccessDenied != null) unawaited(onAccessDenied!());
          throw failure;
        }
        if (failure.code != 'NETWORK_ERROR' || attempt == 1) throw failure;
      }
    }
    throw const BackendFailure('SERVICE_UNAVAILABLE');
  }
}
