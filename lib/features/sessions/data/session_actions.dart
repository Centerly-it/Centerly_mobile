import '../../../core/api/teacher_read_client.dart';
import '../../../core/errors/backend_failure.dart';

/// Writes are never automatically retried: reconcile server state after ambiguity.
class SessionActions {
  const SessionActions(this.api);
  final TeacherReadClient api;
  Future<void> cancel(String id, String reason) async {
    if (reason.trim().isEmpty || reason.length > 500) {
      throw const BackendFailure('VALIDATION_ERROR');
    }
    final generation = api.cache.generation;
    final identity = api.client.auth.currentUser?.id;
    try {
      await api.client
          .rpc(
            'cancel_session',
            params: {'p_session_id': id, 'p_reason': reason.trim()},
          )
          .timeout(const Duration(seconds: 15));
      if (generation != api.cache.generation ||
          identity != api.client.auth.currentUser?.id) {
        throw const BackendFailure('AUTH_REQUIRED');
      }
    } catch (error) {
      final failure = mapBackendFailure(error);
      if (failure.deniesAccess && api.onAccessDenied != null) {
        await api.onAccessDenied!();
      }
      throw failure;
    } finally {
      api.invalidate();
    }
  }
}
