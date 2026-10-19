import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_reads.dart';
import '../../../core/data/read_page.dart';
import '../domain/student_record.dart';
import '../domain/student_membership.dart';

class StudentProfileRepository {
  const StudentProfileRepository(this.api);
  final TeacherReadClient api;
  Future<ReadPage<StudentMembership, StudentRecord>> load(
    String id, {
    String? cursor,
  }) => CompletionReads(api).page(
    TeacherRead.studentProfile,
    params: {'p_id': id, 'p_cursor': cursor, 'p_limit': 30},
    rowsKey: 'memberships',
    countKey: 'membership_count',
    row: StudentMembership.fromJson,
    summary: (j) {
      final student = StudentRecord.fromJson(readMap(j['student']));
      if (student.id != id) throw const FormatException('Unexpected student');
      return student;
    },
  );
}
