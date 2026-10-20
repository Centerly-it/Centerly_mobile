import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_contracts.dart';
import '../../../core/errors/backend_failure.dart';
import '../../../core/format/cairo_time.dart';
import '../domain/dashboard_summary.dart';

class DashboardRepository {
  const DashboardRepository(this.api);
  final TeacherReadClient api;
  Future<DashboardSummary> load({bool refresh = false, String? date}) async {
    // Cairo date defaults on the server; device timezone/clock does not decide it.
    final checkSession = api.sessionGuard();
    final data = await api.read(
      TeacherRead.overview,
      refresh: refresh,
      params: date == null ? null : {'p_date': date},
    );
    try {
      final json = Map<String, dynamic>.from(data as Map);
      final summary = DashboardSummary.fromJson(json);
      final named = await api.read(
        CompletionContracts.enabled
            ? TeacherRead.calendar
            : TeacherRead.namedSessions,
        refresh: refresh,
        params: {
          'p_from': summary.localDate,
          'p_to': summary.localDate,
          'p_group_id': null,
        },
      );
      final rows = CompletionContracts.enabled
          ? (named as Map)['sessions']
          : named;
      final names = {for (final row in rows as List) row['id']: row};
      json['today_sessions'] = [
        for (final row in json['today_sessions'] as List)
          {
            ...Map<String, dynamic>.from(row as Map),
            'group_name': names[row['id']]['group_name'] as String,
            'subject_name': names[row['id']]['subject_name'] as String,
            if (CompletionContracts.enabled)
              'status': names[row['id']]['status'] as String,
          },
      ];
      if (CompletionContracts.enabled) {
        final current = date == null
            ? json
            : Map<String, dynamic>.from(
                await api.read(TeacherRead.overview, refresh: refresh) as Map,
              );
        final today = DateTime.parse(current['date'] as String);
        final finance = Map<String, dynamic>.from(
          await api.read(
                TeacherRead.finance,
                refresh: refresh,
                params: {
                  'p_from': CairoTime.date(DateTime(today.year, today.month)),
                  'p_to': CairoTime.date(
                    DateTime(today.year, today.month + 1, 0),
                  ),
                  'p_kind': 'invoices',
                  'p_limit': 1,
                },
              )
              as Map,
        );
        final totals = Map<String, dynamic>.from(finance['summary'] as Map);
        json['invoiced_egp'] = totals['invoiced_egp'];
        // This card reconciles with this month's due invoices, not receipt dates.
        json['collected_egp'] = totals['paid_against_invoices_egp'];
        json['outstanding_egp'] = totals['outstanding_egp'];
      }
      checkSession();
      return DashboardSummary.fromJson(json);
    } on BackendFailure {
      rethrow;
    } catch (_) {
      throw const BackendFailure('SERVICE_UNAVAILABLE');
    }
  }
}
