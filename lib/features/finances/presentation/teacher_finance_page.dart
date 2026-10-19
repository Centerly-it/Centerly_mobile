import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_reads.dart';
import '../../../core/data/read_page.dart';
import '../../../core/di/di.dart';
import '../../../shared/presentation/filtered_report_page.dart';
import '../../dashboard/presentation/dashboard_metrics.dart';
import '../domain/finance_record.dart';
import 'finance_record_card.dart';

class TeacherFinancePage extends StatelessWidget {
  const TeacherFinancePage({
    required this.initialDate,
    this.studentId,
    super.key,
  });
  final DateTime initialDate;
  final String? studentId;
  @override
  Widget build(BuildContext context) =>
      FilteredReportPage<FinanceRecord, FinanceSummary>(
        title: 'nav_finance',
        initialDate: initialDate,
        collectorFilter: true,
        kinds: const {
          'invoices': 'completion_invoices',
          'payments': 'completion_payments',
        },
        loader: (filters, cursor) =>
            CompletionReads(getIt<TeacherReadClient>()).page(
              TeacherRead.finance,
              params: {
                'p_student_id': studentId,
                ...filters,
                'p_cursor': cursor,
                'p_limit': 30,
              },
              row: FinanceRecord.fromJson,
              summary: (j) => FinanceSummary.fromJson(readMap(j['summary'])),
            ),
        identity: (r) => r.id,
        header: (context, p) => Column(
          children: [
            Text('completion_finance_basis'.tr()),
            for (final e in p.summary.daily.entries)
              Text(
                'completion_daily_collection'.tr(
                  args: [e.key, e.value.decimal],
                ),
              ),
            DashboardMetrics(
              values: {
                for (final e in p.summary.values.entries)
                  'completion_${e.key}': e.value.decimal,
              },
            ),
          ],
        ),
        item: (context, r) => FinanceRecordCard(record: r),
      );
}
