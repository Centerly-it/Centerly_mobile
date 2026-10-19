import '../../../core/api/teacher_read_client.dart';
import '../../../core/errors/backend_failure.dart';
import '../../../core/data/read_page.dart';
import '../domain/student_note.dart';

class StudentNoteRepository {
  const StudentNoteRepository(this.api);
  final TeacherReadClient api;
  Future<StudentNote> load(String student) async {
    final data = await api.read(
      TeacherRead.studentNote,
      params: {'p_id': student},
      refresh: true,
    );
    try {
      return StudentNote.fromJson(readMap(data));
    } catch (_) {
      throw const BackendFailure('SERVICE_UNAVAILABLE');
    }
  }

  Future<void> save(String student, String content, String? version) async {
    if (content.length > 10000) throw const BackendFailure('VALIDATION_ERROR');
    final guard = api.sessionGuard();
    try {
      await api.client
          .rpc(
            'save_teacher_note',
            params: {
              'p_student_id': student,
              'p_content': content,
              'p_expected_updated_at': version,
            },
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
