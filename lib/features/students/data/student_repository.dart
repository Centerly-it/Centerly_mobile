import '../../../core/api/teacher_read_client.dart';
import '../../../core/errors/backend_failure.dart';
import '../domain/student_record.dart';

class StudentRepository {
  const StudentRepository(this.api);
  final TeacherReadClient api;
  Future<StudentPage> list({
    String? search,
    String? groupId,
    String? cursor,
    int limit = 30,
    bool refresh = false,
  }) async {
    if (limit < 1 || limit > 100 || (search?.length ?? 0) > 200) {
      throw const BackendFailure('VALIDATION_ERROR');
    }
    final data = await api.read(
      TeacherRead.students,
      refresh: refresh,
      params: {
        'p_search': search?.trim(),
        'p_group_id': groupId,
        'p_cursor': cursor,
        'p_limit': limit,
      },
    );
    try {
      final records = (data as List)
          .map(
            (row) =>
                StudentRecord.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .toList(growable: false);
      return StudentPage(
        List.unmodifiable(records),
        records.length == limit ? records.last.id : null,
      );
    } catch (_) {
      throw const BackendFailure('SERVICE_UNAVAILABLE');
    }
  }
}
