import '../../../core/api/teacher_read_client.dart';
import '../../../core/errors/backend_failure.dart';
import '../domain/session_record.dart';

class SessionRepository {
  const SessionRepository(this.api);
  final TeacherReadClient api;
  Future<List<SessionRecord>> list({
    required String from,
    required String to,
    String? groupId,
  }) async {
    DateTime? calendarDate(String value) {
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return null;
      final parsed = DateTime.tryParse('${value}T00:00:00Z');
      return parsed?.toIso8601String().substring(0, 10) == value
          ? parsed
          : null;
    }

    final start = calendarDate(from), end = calendarDate(to);
    if (start == null ||
        end == null ||
        end.isBefore(start) ||
        end.difference(start).inDays > 61) {
      throw const BackendFailure('VALIDATION_ERROR');
    }
    final data = await api.read(
      TeacherRead.sessions,
      params: {'p_from': from, 'p_to': to, 'p_group_id': groupId},
    );
    try {
      return List.unmodifiable(
        (data as List).map(
          (row) =>
              SessionRecord.fromJson(Map<String, dynamic>.from(row as Map)),
        ),
      );
    } catch (_) {
      throw const BackendFailure('SERVICE_UNAVAILABLE');
    }
  }
}
