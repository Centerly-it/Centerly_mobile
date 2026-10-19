import '../../../core/api/teacher_read_client.dart';
import '../../../core/errors/backend_failure.dart';
import '../domain/session_detail.dart';

class SessionDetailRepository {
  const SessionDetailRepository(this.api);
  final TeacherReadClient api;
  static const statuses = ['present', 'absent', 'excused', 'not_marked'];
  Future<SessionDetail> load(
    String id, {
    String? status,
    String? cursor,
    int limit = 30,
    bool refresh = false,
  }) async {
    if (id.isEmpty ||
        limit < 1 ||
        limit > 100 ||
        (status != null && !statuses.contains(status))) {
      throw const BackendFailure('VALIDATION_ERROR');
    }
    final result = await api.read(
      TeacherRead.sessionDetail,
      refresh: refresh,
      params: {
        'p_id': id,
        'p_status': status,
        'p_cursor': cursor,
        'p_limit': limit,
      },
    );
    try {
      final detail = SessionDetail.fromJson(
        Map<String, dynamic>.from(result as Map),
      );
      if (detail.session.id != id ||
          detail.rows.length > limit ||
          (cursor != null && detail.nextCursor == cursor)) {
        throw const FormatException('Invalid detail page');
      }
      return detail;
    } catch (_) {
      throw const BackendFailure('SERVICE_UNAVAILABLE');
    }
  }
}
