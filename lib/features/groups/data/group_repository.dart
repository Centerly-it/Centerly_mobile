import '../../../core/api/teacher_read_client.dart';
import '../../../core/errors/backend_failure.dart';
import '../domain/group_record.dart';

/// Prepared contract: activate only after the reviewed migration is deployed.
class GroupRepository {
  const GroupRepository(this.api);
  final TeacherReadClient api;
  Future<({List<GroupRecord> groups, String? nextCursor})> list({
    String? search,
    String? gradeId,
    String? cursor,
    int limit = 30,
    bool refresh = false,
  }) async {
    if (limit < 1 || limit > 100 || (search?.length ?? 0) > 200) {
      throw const BackendFailure('VALIDATION_ERROR');
    }
    final data = await api.read(
      TeacherRead.groups,
      refresh: refresh,
      params: {
        'p_search': search?.trim(),
        'p_grade_level_id': gradeId,
        'p_cursor': cursor,
        'p_limit': limit,
      },
    );
    try {
      final rows = (data as List)
          .map(
            (row) =>
                GroupRecord.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .toList();
      return (
        groups: List<GroupRecord>.unmodifiable(rows),
        nextCursor: rows.length == limit ? rows.last.id : null,
      );
    } catch (_) {
      throw const BackendFailure('SERVICE_UNAVAILABLE');
    }
  }
}
