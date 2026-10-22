import '../domain/finance_movements_summary.dart';
import '../domain/finance_receipt.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_reads.dart';
import '../../../core/data/read_page.dart';
import '../../../core/errors/backend_failure.dart';
import '../domain/finance_due.dart';
import '../domain/finance_overview_data.dart';

class FinanceRepository {
  const FinanceRepository(this.api);
  final TeacherReadClient api;
  // Approved migration 202610220001 deployed and verified on centerly-dev.
  static const movementFilters = bool.fromEnvironment(
    'CENTERLY_FINANCE_MOVEMENT_FILTERS',
    defaultValue: true,
  );
  Future<ReadPage<Map<String, dynamic>, FinanceMovementsSummary>> movements(
    Map<String, dynamic> filters,
    String? cursor,
  ) => CompletionReads(api).page(
    movementFilters ? TeacherRead.financeMovements : TeacherRead.finance,
    params: {
      ...filters,
      if (!movementFilters) 'p_kind': 'payments',
      'p_cursor': cursor,
      'p_limit': 30,
    },
    row: validatedReceipt,
    summary: (j) => FinanceMovementsSummary(
      readMap(j['summary']),
      filtered: movementFilters,
    ),
  );
  Future<FinanceOverviewData> overview(Map<String, dynamic> dates) async {
    final value = await api.read(
      TeacherRead.financeOverview,
      params: dates,
      refresh: true,
    );
    try {
      return FinanceOverviewData(readMap(value));
    } catch (_) {
      throw const BackendFailure('SERVICE_UNAVAILABLE');
    }
  }

  Future<ReadPage<FinanceDue, FinanceDuesSummary>> dues(
    Map<String, dynamic> filters,
    String? cursor,
  ) => CompletionReads(api).page(
    TeacherRead.financeDues,
    params: {...filters, 'p_cursor': cursor, 'p_limit': 30},
    row: FinanceDue.new,
    summary: FinanceDuesSummary.new,
  );
  Future<ReadPage<Map<String, dynamic>, FinanceDue>> invoice(
    String id,
    String? cursor,
  ) => CompletionReads(api).page(
    TeacherRead.invoiceDetail,
    params: {'p_id': id, 'p_cursor': cursor, 'p_limit': 30},
    row: (j) {
      final row = validatedReceipt(j);
      if (row['invoice_id'] != id) throw const FormatException('Wrong invoice');
      return row;
    },
    summary: (j) {
      final invoice = FinanceDue(readMap(j['invoice']));
      if (invoice.id != id) throw const FormatException('Wrong invoice');
      return invoice;
    },
  );
}
