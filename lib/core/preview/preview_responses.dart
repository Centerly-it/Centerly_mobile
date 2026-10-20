import '../format/cairo_time.dart';
import 'preview_sessions.dart';

class PreviewResponses {
  PreviewResponses(this.data);
  final Map<String, dynamic> data;
  final sessions = PreviewSessions();
  dynamic call(String rpc, Map<String, dynamic> p) {
    final now = DateTime.now().toUtc().toIso8601String();
    final date =
        p['p_date'] as String? ??
        CairoTime.date(CairoTime.local(DateTime.now()));
    switch (rpc) {
      case 'get_teacher_overview':
      case 'get_teacher_dashboard':
        return {
          'date': date,
          'total_students': 72,
          'total_groups': 3,
          'today_sessions': sessions.list(date),
          'collected_egp': '12000.00',
          'outstanding_egp': '6000.00',
          'attendance_counts': {
            'present': 42,
            'absent': 5,
            'excused': 3,
            'not_marked': 2,
          },
        };
      case 'get_teacher_calendar':
        return {
          'sessions': sessions.list(p['p_from'] as String? ?? date),
          'synced_at': now,
        };
      case 'list_sessions':
      case 'list_teacher_sessions':
        return sessions.list(p['p_from'] as String? ?? date);
      case 'get_teacher_session_detail':
        return sessions.detail(p, data['students'] as List);
      case 'cancel_session':
        return sessions.cancel(p);
      case 'list_students':
      case 'list_teacher_groups':
        final rows =
            data[rpc == 'list_students' ? 'students' : 'groups'] as List;
        return rows
            .where(
              (r) => '${r['full_name'] ?? r['name']}'.contains(
                p['p_search'] ?? '',
              ),
            )
            .toList();
      case 'get_teacher_student_profile':
        return {
          ...data['profile'] as Map,
          'student': (data['students'] as List).firstWhere(
            (s) => s['id'] == p['p_id'],
            orElse: () => data['profile']['student'],
          ),
          'synced_at': now,
        };
      case 'get_teacher_student_academics':
        return data[p['p_kind'] == 'assignments' ? 'assignments' : 'exams'];
      case 'get_teacher_student_attendance':
        return data['attendance'];
      case 'get_teacher_finance':
        return data[p['p_kind'] == 'payments' ? 'payments' : 'invoices'];
      case 'get_teacher_student_note':
        return data['note'];
      case 'save_teacher_note':
        data['note'] = {
          'note': {'content': p['p_content'], 'updated_at': now},
          'synced_at': now,
        };
        return null;
      case 'list_teacher_secretaries':
        return data['secretaries'];
      case 'list_teacher_notifications':
        return data['notifications'];
      case 'mark_notification_read':
        for (final row in data['notifications']['rows']) {
          if (row['id'] == p['p_id']) row['read_at'] = now;
        }
        data['notifications']['unread_count'] =
            (data['notifications']['rows'] as List)
                .where((r) => r['read_at'] == null)
                .length;
        return null;
      case 'request_secretary_removal':
        for (final row in data['secretaries']['rows']) {
          if (row['id'] == p['p_secretary_id']) {
            row['removal_request'] = {
              'id': '70000000-0000-0000-0000-000000000001',
              'status': 'pending',
              'requested_at': now,
              'handled_at': null,
            };
          }
        }
        return null;
      default:
        throw StateError('Unsupported local preview operation: $rpc');
    }
  }
}
