import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/core/errors/backend_failure.dart';
import 'package:centrally/features/dashboard/data/dashboard_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/read_client_fixture.dart';

void main() {
  test(
    'overview combines exact amounts, manual counts and scoped session names',
    () async {
      final client = readFixture(
        (request) async => jsonResponse(
          request,
          request.url.path.endsWith('get_teacher_overview')
              ? {
                  'date': '2026-10-19',
                  'total_students': 3,
                  'total_groups': 1,
                  'collected_egp': '12.5',
                  'outstanding_egp': '87.50',
                  'attendance_counts': {
                    'present': 1,
                    'absent': 0,
                    'excused': 0,
                    'not_marked': 2,
                  },
                  'today_sessions': [
                    {
                      'id': 'session',
                      'group_id': 'group',
                      'local_date': '2026-10-19',
                      'starts_at': '2026-10-19T08:00:00Z',
                      'ends_at': '2026-10-19T09:00:00Z',
                      'status': 'upcoming',
                    },
                  ],
                }
              : {
                  'sessions': [
                    {
                      'id': 'session',
                      'group_name': 'أولى ثانوي',
                      'subject_name': 'الرياضيات',
                      'status': 'completed',
                    },
                  ],
                },
        ),
      );
      final summary = await DashboardRepository(
        TeacherReadClient(client),
      ).load();
      expect(summary.collectedEgp, '12.50');
      expect(summary.attendance.notMarked, 2);
      expect(summary.sessions.single.groupName, 'أولى ثانوي');
      expect(summary.scheduledMinutes, 60);
      await client.dispose();
    },
  );
  test(
    'session change between overview and name reads rejects the whole summary',
    () async {
      late TeacherReadClient api;
      final client = readFixture((request) async {
        if (request.url.path.endsWith('get_teacher_overview')) {
          return jsonResponse(request, {
            'date': '2026-10-19',
            'total_students': 3,
            'total_groups': 1,
            'collected_egp': '0',
            'outstanding_egp': '0',
            'today_sessions': [],
            'attendance_counts': {
              'present': 0,
              'absent': 0,
              'excused': 0,
              'not_marked': 0,
            },
          });
        }
        api.invalidate();
        return jsonResponse(request, []);
      });
      api = TeacherReadClient(client);
      await expectLater(
        DashboardRepository(api).load(),
        throwsA(
          isA<BackendFailure>().having((e) => e.code, 'code', 'AUTH_REQUIRED'),
        ),
      );
      await client.dispose();
    },
  );
}
