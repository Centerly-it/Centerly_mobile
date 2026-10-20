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
    final guard = api.sessionGuard();
    try {
      await api.client
          .rpc(
            'cancel_session',
            params: {'p_session_id': id, 'p_reason': reason.trim()},
          )
          .timeout(const Duration(seconds: 15));
      guard();
    } catch (error) {
      guard();
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
