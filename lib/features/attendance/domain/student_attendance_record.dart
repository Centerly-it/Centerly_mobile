import '../../../core/data/read_page.dart';

class StudentAttendanceRecord {
  const StudentAttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.status,
    required this.date,
    required this.sessionStatus,
    required this.updatedAt,
    this.group,
    this.actor,
  });
  final String id, sessionId, status, date, sessionStatus;
  final String? group, actor;
  final DateTime updatedAt;
  factory StudentAttendanceRecord.fromJson(Map<String, dynamic> j) {
    if (!['present', 'absent', 'excused', 'not_marked'].contains(j['status'])) {
      throw const FormatException('Invalid mark');
    }
    return StudentAttendanceRecord(
      id: j['id'] as String,
      sessionId: j['session_id'] as String,
      status: j['status'] as String,
      date: j['local_date'] as String,
      sessionStatus: j['session_status'] as String,
      updatedAt: DateTime.parse(j['updated_at'] as String),
      group: j['group_name'] as String?,
      actor: j['marked_by_name'] as String?,
    );
  }
}

class StudentAttendanceSummary {
  const StudentAttendanceSummary(this.counts, this.denominator, this.cancelled);
  final Map<String, int> counts;
  final int denominator, cancelled;
  factory StudentAttendanceSummary.fromJson(Map<String, dynamic> j) {
    final counts = {
      for (final key in ['present', 'absent', 'excused', 'not_marked'])
        key: readCount(j[key]),
    };
    final denominator = readCount(j['marked_denominator']);
    if (denominator !=
        counts['present']! + counts['absent']! + counts['excused']!) {
      throw const FormatException('Invalid denominator');
    }
    return StudentAttendanceSummary(
      Map.unmodifiable(counts),
      denominator,
      readCount(j['cancelled_records']),
    );
  }
}
