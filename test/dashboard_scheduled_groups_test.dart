import 'package:centrally/features/dashboard/domain/attendance_counts.dart';
import 'package:centrally/features/dashboard/domain/dashboard_summary.dart';
import 'package:centrally/features/sessions/domain/session_record.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:flutter_test/flutter_test.dart';

SessionRecord lesson(
  String id,
  String group, {
  String date = '2026-10-27',
  SessionStatus status = SessionStatus.upcoming,
}) => SessionRecord(
  id: id,
  groupId: group,
  localDate: date,
  startsAt: DateTime.utc(2026, 10, 27, 12),
  endsAt: DateTime.utc(2026, 10, 27, 13),
  status: status,
);
DashboardSummary summary(List<SessionRecord> sessions) => DashboardSummary(
  students: 50,
  groups: 12,
  collectedEgp: '10.00',
  outstandingEgp: '20.00',
  localDate: '2026-10-27',
  attendance: const AttendanceCounts(
    present: 0,
    absent: 0,
    excused: 0,
    notMarked: 0,
  ),
  sessions: sessions,
);
void main() {
  test(
    'daily group count uses distinct scheduled groups, not teacher total',
    () {
      final data = summary([
        lesson('one', 'group-a'),
        lesson('two', 'group-a', status: SessionStatus.completed),
      ]);
      expect(data.scheduledGroups, 1);
      expect(data.groups, 12);
      expect(
        summary([
          lesson('one', 'group-a'),
          lesson('two', 'group-b'),
        ]).scheduledGroups,
        2,
      );
    },
  );
  test('no lessons, cancelled-only groups and other dates do not count', () {
    expect(summary([]).scheduledGroups, 0);
    expect(
      summary([
        lesson('cancelled', 'group-a', status: SessionStatus.cancelled),
        lesson('tomorrow', 'group-b', date: '2026-10-28'),
      ]).scheduledGroups,
      0,
    );
  });
}
