import '../../../models/centerly_models.dart';

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.name,
    required this.status,
    required this.updatedAt,
    this.markedAt,
    this.marker,
  });
  final String id, studentId, name;
  final AttendanceStatus status;
  final DateTime updatedAt;
  final DateTime? markedAt;
  final String? marker;
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'] as String,
        studentId: json['student_id'] as String,
        name: json['full_name'] as String,
        status: switch (json['status']) {
          'present' => AttendanceStatus.present,
          'absent' => AttendanceStatus.absent,
          'excused' => AttendanceStatus.excused,
          'not_marked' => AttendanceStatus.notMarked,
          _ => throw const FormatException('Invalid attendance status'),
        },
        updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
        markedAt: json['marked_at'] == null
            ? null
            : DateTime.parse(json['marked_at'] as String).toUtc(),
        marker: json['marked_by_name'] as String?,
      );
}
