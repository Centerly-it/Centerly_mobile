import 'student_preview_data.dart';

class StudentPreviewFilters {
  final values = <String, Set<String>>{'level': {}, 'group': {}, 'payment': {}};
  bool matches(StudentPreviewData student, String query) =>
      student.name.toLowerCase().contains(query.toLowerCase()) &&
      (values['level']!.isEmpty || values['level']!.contains(student.level)) &&
      (values['group']!.isEmpty ||
          values['group']!.contains('group_${student.group}')) &&
      (values['payment']!.isEmpty ||
          values['payment']!.contains(student.paid ? 'paid' : 'unpaid'));
  void clear() {
    for (final selected in values.values) {
      selected.clear();
    }
  }
}
