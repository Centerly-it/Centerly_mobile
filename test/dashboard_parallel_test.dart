import 'dart:async';
import 'package:centrally/core/api/teacher_read_client.dart';
import 'package:centrally/features/dashboard/data/dashboard_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/read_client_fixture.dart';

void main() {
  test(
    'finance starts before pending calendar resolves, without bypassing guards',
    () async {
      final calendar = Completer<void>(),
          finance = Completer<void>(),
          release = Completer<void>();
      final client = readFixture((r) async {
        if (r.url.path.endsWith('get_teacher_overview')) {
          return jsonResponse(r, {
            'date': '2026-10-20',
            'total_students': 1,
            'total_groups': 1,
            'collected_egp': '0.00',
            'outstanding_egp': '0.00',
            'attendance_counts': {
              'present': 0,
              'absent': 0,
              'excused': 0,
              'not_marked': 1,
            },
            'today_sessions': [],
          });
        }
        if (r.url.path.endsWith('get_teacher_calendar')) {
          calendar.complete();
          await release.future;
          return jsonResponse(r, {'sessions': []});
        }
        finance.complete();
        return jsonResponse(r, {
          'summary': {
            'invoiced_egp': '100.01',
            'paid_against_invoices_egp': '40.01',
            'outstanding_egp': '60.00',
            'period_net_collected_egp': '50.01',
            'daily_collections': [
              {'date': '2026-10-20', 'net_egp': '50.01'},
            ],
          },
        });
      });
      addTearDown(client.dispose);
      final pending = DashboardRepository(TeacherReadClient(client)).load();
      await calendar.future;
      await finance.future;
      release.complete();
      final data = await pending;
      expect(data.collectedEgp, '40.01');
      expect(data.outstandingEgp, '60.00');
    },
  );
}
