import 'package:centrally/features/dashboard/domain/dashboard_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> overview() => {
    'date': '2030-01-01',
    'total_students': 5,
    'total_groups': 1,
    'collected_egp': '0.00',
    'outstanding_egp': '0.00',
    'today_sessions': [],
    'attendance_counts': {
      'present': 2,
      'absent': 0,
      'excused': 0,
      'not_marked': 3,
    },
  };
  test(
    'legacy selected-day counts cannot be presented as current attendance',
    () {
      expect(DashboardSummary.fromJson(overview()).attendanceSyncedAt, isNull);
    },
  );
  test('ongoing snapshot is independent of the dashboard selected day', () {
    final summary = DashboardSummary.fromJson({
      ...overview(),
      'attendance_scope': 'ongoing_sessions',
      'attendance_synced_at': '2026-10-20T08:00:00Z',
    });
    expect(summary.localDate, '2030-01-01');
    expect(summary.attendanceSyncedAt, DateTime.utc(2026, 10, 20, 8));
    expect(summary.attendance.notMarked, 3);
    expect(summary.attendance.absent, 0);
  });
}
