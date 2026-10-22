class SessionDesignData {
  SessionDesignData({
    required this.id,
    required this.date,
    required this.start,
    required this.end,
    required this.group,
    required this.subject,
    required this.grade,
    required this.students,
    this.current = false,
    this.hasAttendanceCounts = true,
    this.completed = false,
  });
  final String id, group, subject, grade;
  final DateTime date, start, end;
  final List<SessionStudentData> students;
  final bool current, completed, hasAttendanceCounts;
  String? cancellationReason;
  int get present => students.where((s) => s.status == 'present').length;
  int get expected => students.length;
}

class SessionStudentData {
  const SessionStudentData({
    required this.id,
    required this.name,
    required this.group,
    required this.status,
  });
  final String id, name, group, status;
}
