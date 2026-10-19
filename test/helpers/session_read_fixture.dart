import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'read_client_fixture.dart';

class SessionReadFixture {
  final ranges = <Map>[];
  bool cancelled = false;
  SupabaseClient client() => readFixture((request) async {
    if (request.url.path.endsWith('get_teacher_overview')) {
      return jsonResponse(request, {
        'date': '2026-07-01',
        'total_students': 1,
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
    if (request.url.path.endsWith('cancel_session')) {
      expect(jsonDecode(request.body), {
        'p_session_id': 'one',
        'p_reason': 'Teacher unavailable',
      });
      cancelled = true;
      return jsonResponse(request, null);
    }
    ranges.add(jsonDecode(request.body) as Map);
    final rows = ranges.last['p_from'] != ranges.last['p_to']
        ? []
        : [
            {
              'group_name': 'Group A',
              'subject_name': 'Math',
              'id': 'one',
              'group_id': 'group',
              'local_date': '2026-07-01',
              'starts_at': '2026-07-01T21:00:00Z',
              'ends_at': '2026-07-01T22:00:00Z',
              'status': cancelled ? 'cancelled' : 'upcoming',
              'attendance_finalized_at': null,
            },
          ];
    return jsonResponse(
      request,
      request.url.path.endsWith('get_teacher_calendar')
          ? {'sessions': rows}
          : rows,
    );
  });
}
