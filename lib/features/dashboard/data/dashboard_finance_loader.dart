import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_contracts.dart';
import '../../../core/format/calendar_month.dart';
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
    params: {...calendarMonthDates(today), 'p_kind': 'invoices', 'p_limit': 1},
  );
  return FinanceSummary.fromJson(
    Map<String, dynamic>.from((response as Map)['summary'] as Map),
  );
}
