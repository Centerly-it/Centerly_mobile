import 'dashboard_finance_loader.dart';
import '../../finances/domain/finance_summary.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_contracts.dart';
import '../../../core/errors/backend_failure.dart';
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
      final reads = await Future.wait<dynamic>([
        api.read(
          CompletionContracts.enabled
              ? TeacherRead.calendar
              : TeacherRead.namedSessions,
          refresh: refresh,
          params: {
            'p_from': summary.localDate,
            'p_to': summary.localDate,
            'p_group_id': null,
          },
        ),
        loadDashboardFinance(
          api,
          json,
          refresh: refresh,
          selectedDate: date != null,
        ),
      ], eagerError: true);
      final named = reads[0];
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
      final totals = reads[1] as FinanceSummary?;
      if (totals != null) {
        json['invoiced_egp'] = totals.values['invoiced_egp']!.decimal;
        json['collected_egp'] =
            totals.values['paid_against_invoices_egp']!.decimal;
        json['outstanding_egp'] = totals.values['outstanding_egp']!.decimal;
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
