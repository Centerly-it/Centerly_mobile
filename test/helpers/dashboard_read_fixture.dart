import 'package:supabase_flutter/supabase_flutter.dart';
import 'read_client_fixture.dart';

class DashboardReadFixture {
  bool fail = false;
  int calls = 0;
  SupabaseClient client() => readFixture((request) async {
    if (request.url.path.endsWith('list_teacher_sessions')) {
      return jsonResponse(request, []);
    }
    calls++;
    return jsonResponse(
      request,
      fail
          ? {'message': 'unavailable'}
          : {
              'today_sessions': [],
              'attendance_counts': {
                'present': 0,
                'absent': 0,
                'excused': 0,
                'not_marked': 0,
              },
              'total_students': 12,
              'total_groups': 3,
              'date': '2026-10-19',
              'collected_egp': '125.50',
              'outstanding_egp': '20.00',
            },
      status: fail ? 500 : 200,
    );
  });
}
