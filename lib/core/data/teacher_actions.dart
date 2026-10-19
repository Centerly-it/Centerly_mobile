import '../api/teacher_read_client.dart';
import '../errors/backend_failure.dart';

class TeacherActions {
  const TeacherActions(this.api);
  final TeacherReadClient api;
  Future<void> requestRemoval(String id) =>
      _write('request_secretary_removal', {'p_secretary_id': id});
  Future<void> markRead(String id) =>
      _write('mark_notification_read', {'p_id': id});
  Future<void> _write(String rpc, Map<String, dynamic> params) async {
    final guard = api.sessionGuard();
    try {
      await api.client
          .rpc(rpc, params: params)
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
