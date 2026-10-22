import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/presentation/paged_read_cubit.dart';
import '../data/finance_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_reads.dart';
import '../../../core/data/read_page.dart';
import '../../../core/di/di.dart';
import '../../../shared/presentation/filtered_report_page.dart';
import '../../dashboard/presentation/dashboard_metrics.dart';
import '../domain/finance_record.dart';
import 'student_finance_record_card.dart';

class TeacherFinancePage extends StatelessWidget {
  const TeacherFinancePage({
    required this.initialDate,
    this.studentId,
    this.embedded = false,
    super.key,
  });
  final DateTime initialDate;
  final bool embedded;
  final String? studentId;
  @override
  Widget build(BuildContext context) =>
      FilteredReportPage<FinanceRecord, FinanceSummary>(
        embedded: embedded,
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
        item: (context, r) => StudentFinanceRecordCard(
          record: r,
          syncedAt: context
              .read<PagedReadCubit<FinanceRecord, FinanceSummary>>()
              .state
              .page!
              .syncedAt,
          repository: FinanceRepository(getIt<TeacherReadClient>()),
        ),
      );
}
