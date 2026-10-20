import '../../sessions/domain/session_record.dart';
import 'attendance_counts.dart';
import '../../../models/centerly_models.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.students,
    required this.groups,
    required this.collectedEgp,
    required this.outstandingEgp,
    this.invoicedEgp,
    required this.localDate,
    required this.attendance,
    this.sessions = const [],
  });
  final int students, groups;
  final String? invoicedEgp;
  final AttendanceCounts attendance;
  final List<SessionRecord> sessions;
  int get scheduledMinutes => sessions
      .where((s) => s.status != SessionStatus.cancelled)
      .fold(0, (total, s) => total + s.endsAt.difference(s.startsAt).inMinutes);
  final String collectedEgp, outstandingEgp, localDate;
  factory DashboardSummary.fromJson(Map<String, dynamic> data) {
    final students = data['total_students'], groups = data['total_groups'];
    final date = data['date'];
    String amount(String key) {
      final raw = data[key];
      if (raw is! num && raw is! String) {
        throw const FormatException('Invalid server amount');
      }
      final text = raw.toString();
      if (!RegExp(r'^-?\d+(\.\d{1,2})?$').hasMatch(text)) {
        throw const FormatException('Invalid server amount');
      }
      final parts = text.split('.');
      return '${parts.first}.${(parts.length == 1 ? '' : parts.last).padRight(2, '0')}';
    }

    if (students is! int ||
        groups is! int ||
        students < 0 ||
        groups < 0 ||
        date is! String ||
        DateTime.tryParse(date) == null) {
      throw const FormatException('Invalid dashboard summary');
    }
    return DashboardSummary(
      students: students,
      groups: groups,
      localDate: date,
      attendance: AttendanceCounts.fromJson(
        Map<String, dynamic>.from(data['attendance_counts'] as Map),
      ),
      sessions: List.unmodifiable(
        (data['today_sessions'] as List).map(
          (row) =>
              SessionRecord.fromJson(Map<String, dynamic>.from(row as Map)),
        ),
      ),
      invoicedEgp: data.containsKey('invoiced_egp')
          ? amount('invoiced_egp')
          : null,
      collectedEgp: amount('collected_egp'),
      outstandingEgp: amount('outstanding_egp'),
    );
  }
}
