class GroupRecord {
  const GroupRecord({
    required this.id,
    required this.name,
    required this.subject,
    required this.gradeId,
    required this.gradeName,
    required this.capacity,
    required this.students,
    required this.roster,
    required this.schedules,
    required this.schedulesTruncated,
  });
  final String id, name, subject, gradeId, gradeName;
  final int capacity, students;
  final List<({String id, String name})> roster;
  final List<GroupSchedulePreview> schedules;
  final bool schedulesTruncated;
  factory GroupRecord.fromJson(Map<String, dynamic> json) {
    final capacity = json['capacity'] as int,
        students = json['students_count'] as int;
    if (capacity < 1 || students < 0) {
      throw const FormatException('Invalid group counts');
    }
    return GroupRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      subject: json['subject_name'] as String,
      gradeId: json['grade_level_id'] as String,
      gradeName: json['grade_name'] as String,
      capacity: capacity,
      students: students,
      roster: List.unmodifiable(
        (json['roster_preview'] as List).map(
          (row) => (id: row['id'] as String, name: row['full_name'] as String),
        ),
      ),
      schedules: List.unmodifiable(
        (json['schedules'] as List).map(
          (row) => GroupSchedulePreview.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        ),
      ),
      schedulesTruncated: json['schedules_truncated'] as bool,
    );
  }
}

class GroupSchedulePreview {
  const GroupSchedulePreview({
    required this.weekday,
    required this.start,
    required this.end,
    required this.from,
    this.to,
  });
  final int weekday;
  final String start, end, from;
  final String? to;
  factory GroupSchedulePreview.fromJson(Map<String, dynamic> json) {
    final weekday = json['weekday'] as int;
    if (weekday < 0 || weekday > 6) {
      throw const FormatException('Invalid weekday');
    }
    return GroupSchedulePreview(
      weekday: weekday,
      start: json['local_start_time'] as String,
      end: json['local_end_time'] as String,
      from: json['effective_from'] as String,
      to: json['effective_to'] as String?,
    );
  }
}
