import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/backend_failure.dart';
import 'teacher_read_endpoint.dart';

/// Only reads retry. Access denial invalidates before notifying auth navigation.
Future<dynamic> fetchTeacherRead(
  SupabaseClient client,
  TeacherRead endpoint,
  Map<String, dynamic>? params,
  void Function() guard,
  void Function() denied,
) async {
  for (var attempt = 0; attempt < 2; attempt++) {
    try {
      final data = await client
          .rpc(teacherReadNames[endpoint]!, params: params)
          .timeout(const Duration(seconds: 15));
      guard();
      return data;
    } catch (error) {
      guard();
      final failure = mapBackendFailure(error);
      if (failure.deniesAccess) {
        denied();
        throw failure;
      }
      if (failure.code != 'NETWORK_ERROR' || attempt == 1) throw failure;
    }
  }
  throw const BackendFailure('SERVICE_UNAVAILABLE');
}
