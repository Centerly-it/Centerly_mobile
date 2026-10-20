import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_contracts.dart';
import '../../../core/format/cairo_time.dart';
import '../../finances/domain/finance_summary.dart';

Future<FinanceSummary?> loadDashboardFinance(
  TeacherReadClient api,
  Map<String, dynamic> overview, {
  required bool refresh,
  required bool selectedDate,
}) async {
  if (!CompletionContracts.enabled) return null;
  final current = selectedDate
      ? Map<String, dynamic>.from(
          await api.read(TeacherRead.overview, refresh: refresh) as Map,
        )
      : overview;
  final today = DateTime.parse(current['date'] as String);
  final response = await api.read(
    TeacherRead.finance,
    refresh: refresh,
    params: {
      'p_from': CairoTime.date(DateTime.utc(today.year, today.month)),
      'p_to': CairoTime.date(DateTime.utc(today.year, today.month + 1, 0)),
      'p_kind': 'invoices',
      'p_limit': 1,
    },
  );
  return FinanceSummary.fromJson(
    Map<String, dynamic>.from((response as Map)['summary'] as Map),
  );
}
