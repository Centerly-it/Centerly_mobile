import '../domain/attendance_record.dart';
import '../domain/session_detail.dart';

class SessionDetailState {
  const SessionDetailState({
    this.detail,
    this.rows = const [],
    this.status,
    this.loading = false,
    this.error = false,
    this.retryMore = false,
    this.nextCursor,
  });
  final SessionDetail? detail;
  final List<AttendanceRecord> rows;
  final String? status, nextCursor;
  final bool loading, error, retryMore;
}
