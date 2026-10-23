import '../../../core/api/teacher_read_client.dart';
import '../../../core/errors/backend_failure.dart';

// Existing SELECT grant/RLS, restricted explicitly to the signed-in owning teacher.
Future<List<Map<String, dynamic>>> archivedStudents(
  TeacherReadClient api,
  String? search,
  String? cursor,
  int limit,
) async {
  final guard = api.sessionGuard();
  final teacher = api.client.auth.currentUser?.id;
  if (teacher == null) throw const BackendFailure('AUTH_REQUIRED');
  try {
    var query = api.client
        .from('students')
        .select(
          'id,full_name,created_at,phone,guardian_phone,level_tag,archived_at',
        )
        .eq('teacher_id', teacher)
        .not('archived_at', 'is', null);
    if (cursor != null) query = query.gt('id', cursor);
    if (search != null && search.trim().isNotEmpty) {
      query = query.ilike('full_name', '%${search.trim()}%');
    }
    final rows = await query
        .order('id', ascending: true)
        .limit(limit)
        .timeout(const Duration(seconds: 20));
    guard();
    return rows;
  } catch (error) {
    guard();
    throw mapBackendFailure(error);
  }
}
