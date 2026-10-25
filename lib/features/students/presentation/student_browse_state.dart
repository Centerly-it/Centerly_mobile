import '../domain/student_record.dart';

class StudentBrowseState {
  const StudentBrowseState({
    this.students = const [],
    this.search = '',
    this.cursor,
    this.error,
    this.loading = false,
    this.retryMore = false,
  });
  final List<StudentRecord> students;
  final String search;
  final String? cursor, error;
  final bool loading, retryMore;
}
