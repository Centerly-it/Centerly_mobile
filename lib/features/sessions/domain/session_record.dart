import 'session_design_data.dart';
import '../../../models/centerly_models.dart' show SessionStatus;

class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.groupId,
    required this.localDate,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.finalizedAt,
    this.groupName,
    this.subjectName,
  });
  final String id, groupId, localDate;
  final String? groupName, subjectName;
  final DateTime startsAt, endsAt;
  final DateTime? finalizedAt;
  final SessionStatus status;
  SessionDesignData get design => SessionDesignData(
    id: id,
    date: DateTime.parse(localDate),
    start: startsAt,
    end: endsAt,
    group: groupName ?? '',
    subject: subjectName ?? '',
    grade: '',
    students: const [],
    current: status == SessionStatus.ongoing,
    completed: status == SessionStatus.completed,
    hasAttendanceCounts: false,
  )..cancellationReason = status == SessionStatus.cancelled ? '' : null;
  SessionRecord atServerTime(DateTime now) => SessionRecord(
    id: id,
    groupId: groupId,
    localDate: localDate,
    startsAt: startsAt,
    endsAt: endsAt,
    groupName: groupName,
    subjectName: subjectName,
    finalizedAt: finalizedAt,
    status: status == SessionStatus.cancelled
        ? status
        : now.isBefore(startsAt)
        ? SessionStatus.upcoming
        : now.isBefore(endsAt)
        ? SessionStatus.ongoing
        : SessionStatus.completed,
  );
  factory SessionRecord.fromJson(Map<String, dynamic> json) {
    final id = json['id'], group = json['group_id'], date = json['local_date'];
    if (id is! String ||
        group is! String ||
        date is! String ||
        DateTime.tryParse(date) == null) {
      throw const FormatException('Invalid session record');
    }
    final start = DateTime.parse(json['starts_at'] as String).toUtc();
    final end = DateTime.parse(json['ends_at'] as String).toUtc();
    if (!end.isAfter(start)) {
      throw const FormatException('Invalid session interval');
    }
    return SessionRecord(
      id: id,
      groupId: group,
      groupName: json['group_name'] as String?,
      subjectName: json['subject_name'] as String?,
      localDate: date,
      startsAt: start,
      endsAt: end,
      status: SessionStatus.values.byName(json['status'] as String),
      finalizedAt: json['attendance_finalized_at'] == null
          ? null
          : DateTime.parse(json['attendance_finalized_at'] as String).toUtc(),
    );
  }
}
