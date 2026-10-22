import 'package:supabase_flutter/supabase_flutter.dart';
import 'read_client_fixture.dart';

class DashboardReadFixture {
  bool fail = false;
  int calls = 0;
  SupabaseClient client() => readFixture((request) async {
    if (request.url.path.endsWith('list_teacher_sessions')) {
      return jsonResponse(request, []);
    }
    if (request.url.path.endsWith('get_teacher_calendar')) {
      return jsonResponse(request, {'sessions': []});
    }
    if (request.url.path.endsWith('get_teacher_finance_overview')) {
      return jsonResponse(request, {
        'invoiced_egp': '0.00',
        'paid_against_invoices_egp': '0.00',
        'outstanding_egp': '0.00',
        'period_net_collected_egp': '0.00',
        'daily_collections': [],
        'invoice_count': 0,
        'gross_collected_egp': '0.00',
        'corrections_egp': '0.00',
        'overdue_egp': '0.00',
        'due_today_egp': '0.00',
        'future_due_egp': '0.00',
        'actors': [],
        'methods': [],
        'as_of_date': '2026-10-22',
        'synced_at': '2026-10-22T10:00:00Z',
      });
    }
    if (request.url.path.endsWith('get_teacher_finance')) {
      return jsonResponse(request, {
        'rows': [],
        'total_count': 0,
        'next_cursor': null,
        'synced_at': '2026-10-19T10:00:00Z',
        'summary': {
          'invoiced_egp': '0.00',
          'paid_against_invoices_egp': '0.00',
          'outstanding_egp': '0.00',
          'period_net_collected_egp': '0.00',
          'daily_collections': [],
        },
      });
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
