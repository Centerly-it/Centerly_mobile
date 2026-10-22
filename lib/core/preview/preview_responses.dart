import 'preview_finance_movements.dart';
import 'preview_mutations.dart';
import '../../features/finances/preview/finance_preview_summary.dart';
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
        final summary = financePreviewSummary();
        return {
          'date': date,
          'total_students': 72,
          'total_groups': 3,
          'today_sessions': sessions.list(date),
          'invoiced_egp': summary['invoiced_egp'],
          'collected_egp': summary['paid_against_invoices_egp'],
          'outstanding_egp': summary['outstanding_egp'],
          'attendance_scope': 'ongoing_sessions',
          'attendance_synced_at': now,
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
      case 'get_teacher_finance_overview':
        final summary = data['invoices']['summary'] as Map;
        return {
          ...summary,
          'invoice_count': data['invoices']['total_count'],
          'gross_collected_egp': summary['period_net_collected_egp'],
          'corrections_egp': '0.00',
          'overdue_egp': summary['outstanding_egp'],
          'due_today_egp': '0.00',
          'future_due_egp': '0.00',
          'actors': [
            {
              'actor_id': data['payments']['rows'][0]['collected_by'],
              'actor_name': data['payments']['rows'][0]['collected_by_name'],
              'collection_count': 1,
              'correction_count': 0,
              'net_egp': summary['period_net_collected_egp'],
            },
          ],
          'methods': [
            {'method': 'cash', 'net_egp': summary['period_net_collected_egp']},
          ],
          'as_of_date': date,
          'synced_at': now,
        };
      case 'list_teacher_finance_dues':
        return {
          ...data['invoices'] as Map,
          'as_of_date': date,
          'summary': {
            ...data['invoices']['summary'] as Map,
            'net_paid_egp':
                data['invoices']['summary']['paid_against_invoices_egp'],
          },
        };
      case 'get_teacher_invoice_detail':
        return {
          ...data['payments'] as Map,
          'invoice': data['invoices']['rows'][0],
        };
      case 'list_teacher_finance_movements':
        return previewFinanceMovements(data, p);
      case 'get_teacher_finance':
        final response = Map<String, dynamic>.from(
          data[p['p_kind'] == 'payments' ? 'payments' : 'invoices'] as Map,
        );
        if (p['p_student_id'] == null && p['p_group_id'] == null) {
          response['summary'] = financePreviewSummary();
        }
        return response;
      case 'get_teacher_student_note':
        return data['note'];
      case 'list_teacher_secretaries':
        return data['secretaries'];
      case 'list_teacher_notifications':
        return data['notifications'];
      default:
        return previewMutation(rpc, p, data, now);
    }
  }
}
