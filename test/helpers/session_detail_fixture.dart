import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'read_client_fixture.dart';

class SessionDetailFixture {
  final requests = <Map<String, dynamic>>[];
  bool corrected = false;
  bool cancelled = false;
  Map<String, dynamic> response({String? status, String? cursor}) {
    final rows = [
      {
        'id': 'row-a',
        'student_id': 'student-a',
        'full_name': 'Student A',
        'status': corrected ? 'excused' : 'not_marked',
        'updated_at': '2026-10-19T09:00:00Z',
        'marked_at': corrected ? '2026-10-19T09:00:00Z' : null,
        'marked_by_name': corrected ? 'Secretary A' : null,
      },
      {
        'id': 'row-b',
        'student_id': 'student-b',
        'full_name': 'Student B',
        'status': 'present',
        'updated_at': '2026-10-19T08:00:00Z',
        'marked_at': '2026-10-19T08:00:00Z',
        'marked_by_name': 'Secretary A',
      },
    ].where((r) => status == null || r['status'] == status).toList();
    final page = rows
        .where(
          (r) => cursor == null || (r['id'] as String).compareTo(cursor) > 0,
        )
        .toList();
    return {
      'session': {
        'id': 'session-a',
        'group_id': 'group-a',
        'group_name': 'Group A',
        'subject_name': 'Math',
        'local_date': '2026-10-19',
        'starts_at': '2026-10-19T07:00:00Z',
        'ends_at': '2026-10-19T08:00:00Z',
        'status': cancelled ? 'cancelled' : 'completed',
        'attendance_finalized_at': '2026-10-19T08:01:00Z',
        'cancel_reason': cancelled ? 'Retained history' : null,
        'cancelled_by_name': cancelled ? 'Teacher A' : null,
        'cancelled_at': cancelled ? '2026-10-19T06:00:00Z' : null,
      },
      'attendance_counts': {
        'present': 1,
        'absent': 0,
        'excused': corrected ? 1 : 0,
        'not_marked': corrected ? 0 : 1,
      },
      'attendance': page.take(1).toList(),
      'filtered_count': rows.length,
      'next_cursor': page.length > 1 ? page.first['id'] : null,
      'synced_at': '2026-10-19T10:00:00Z',
    };
  }

  SupabaseClient client() => readFixture((request) async {
    final params = Map<String, dynamic>.from(jsonDecode(request.body) as Map);
    requests.add(params);
    return jsonResponse(
      request,
      response(
        status: params['p_status'] as String?,
        cursor: params['p_cursor'] as String?,
      ),
    );
  });
}
