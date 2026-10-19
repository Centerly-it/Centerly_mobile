import 'dart:convert';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/errors/backend_failure.dart';
import 'package:centrally/features/dashboard/domain/dashboard_summary.dart';
import 'package:centrally/features/students/data/student_repository.dart';
import 'package:centrally/features/sessions/domain/session_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/read_client_fixture.dart';

void main() {
  test(
    'dashboard requires server metrics and preserves decimal display values',
    () {
      final data = {
        'today_sessions': [],
        'total_students': 2,
        'total_groups': 1,
        'date': '2026-10-18',
        'collected_egp': '12.50',
        'outstanding_egp': '27.25',
      };
      expect(DashboardSummary.fromJson(data).collectedEgp, '12.50');
      data.remove('total_students');
      expect(() => DashboardSummary.fromJson(data), throwsFormatException);
    },
  );
  test(
    'student pagination sends bounded RPC parameters without tenant input',
    () async {
      var calls = 0;
      final client = readFixture((request) async {
        calls++;
        final body = jsonDecode(request.body) as Map;
        expect(body['p_limit'], 2);
        expect(body['p_cursor'], 'cursor');
        expect(body.containsKey('teacher_id'), isFalse);
        return jsonResponse(request, [
          for (final id in ['one', 'two'])
            {
              'id': id,
              'full_name': 'طالب',
              'created_at': '2026-10-18T00:00:00Z',
            },
        ]);
      });
      final repo = StudentRepository(TeacherReadClient(client));
      final page = await repo.list(cursor: 'cursor', limit: 2);
      expect(page.nextCursor, 'two');
      expect(page.students.first.guardianPhone, isNull);
      await expectLater(repo.list(limit: 101), throwsA(isA<BackendFailure>()));
      expect(calls, 1);
      await client.dispose();
    },
  );
  test('session contract has manual finalization and valid UTC intervals', () {
    final json = {
      'id': 'session',
      'group_id': 'group',
      'local_date': '2026-10-18',
      'starts_at': '2026-10-18T10:00:00+03:00',
      'ends_at': '2026-10-18T11:00:00+03:00',
      'status': 'completed',
      'attendance_finalized_at': null,
    };
    final value = SessionRecord.fromJson(json);
    expect(value.startsAt.hour, 7);
    expect(value.finalizedAt, isNull);
    json['ends_at'] = json['starts_at'];
    expect(() => SessionRecord.fromJson(json), throwsFormatException);
  });
}
