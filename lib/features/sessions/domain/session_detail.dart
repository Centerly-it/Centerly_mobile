import '../../dashboard/domain/attendance_counts.dart';
import 'attendance_record.dart';
import 'session_record.dart';

class SessionDetail {
  const SessionDetail({
    required this.session,
    required this.counts,
    required this.rows,
    required this.filteredCount,
    required this.syncedAt,
    this.nextCursor,
    this.cancelReason,
    this.cancelledBy,
    this.cancelledAt,
  });
  final SessionRecord session;
  final AttendanceCounts counts;
  final List<AttendanceRecord> rows;
  final int filteredCount;
  final DateTime syncedAt;
  final String? nextCursor, cancelReason, cancelledBy;
  final DateTime? cancelledAt;
  factory SessionDetail.fromJson(Map<String, dynamic> json) {
    final session = Map<String, dynamic>.from(json['session'] as Map);
    final count = json['filtered_count'];
    if (count is! int || count < 0) {
      throw const FormatException('Invalid count');
    }
    final rows = (json['attendance'] as List)
        .map(
          (r) => AttendanceRecord.fromJson(Map<String, dynamic>.from(r as Map)),
        )
        .toList();
    if (rows.length > count) throw const FormatException('Invalid page');
    return SessionDetail(
      session: SessionRecord.fromJson(session),
      counts: AttendanceCounts.fromJson(
        Map<String, dynamic>.from(json['attendance_counts'] as Map),
      ),
      rows: List.unmodifiable(rows),
      filteredCount: count,
      syncedAt: DateTime.parse(json['synced_at'] as String).toUtc(),
      nextCursor: json['next_cursor'] as String?,
      cancelReason: session['cancel_reason'] as String?,
      cancelledBy: session['cancelled_by_name'] as String?,
      cancelledAt: session['cancelled_at'] == null
          ? null
          : DateTime.parse(session['cancelled_at'] as String).toUtc(),
    );
  }
}
