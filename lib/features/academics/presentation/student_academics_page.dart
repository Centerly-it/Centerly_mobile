import '../../../core/widgets/content_skeleton.dart';
import '../../../core/theme/values_manager.dart';
import 'live_academic_table.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_reads.dart';
import '../../../core/data/read_page.dart';
import '../../../core/di/di.dart';
import '../../../shared/presentation/filtered_report_page.dart';
import '../../dashboard/presentation/dashboard_metrics.dart';
import '../domain/academic_record.dart';
import 'academic_record_card.dart';

class StudentAcademicsPage extends StatelessWidget {
  const StudentAcademicsPage({
    required this.studentId,
    required this.initialDate,
    this.embedded = false,
    super.key,
  });
  final String studentId;
  final DateTime initialDate;
  final bool embedded;
  @override
  Widget build(BuildContext context) =>
      FilteredReportPage<AcademicRecord, AcademicSummary>(
        embedded: embedded,
        loadingShape: LoadingShape.table,
        title: 'completion_academics',
        initialDate: initialDate,
        kinds: const {
          'exams': 'completion_exams',
          'assignments': 'completion_assignments',
        },
        loader: (filters, cursor) =>
            CompletionReads(getIt<TeacherReadClient>()).page(
              TeacherRead.academics,
              params: {
                'p_id': studentId,
                ...filters,
                'p_cursor': cursor,
                'p_limit': 30,
              },
              row: AcademicRecord.fromJson,
              summary: (j) => AcademicSummary.fromJson(readMap(j['summary'])),
            ),
        identity: (r) => r.id,
        header: (context, page) => Column(
          children: [
            DashboardMetrics(
              values: {
                for (final e in page.summary.values.entries)
                  'completion_${e.key}': '${e.value}',
              },
            ),
            const SizedBox(height: AppSize.s16),
            if (page.summary.values.containsKey('scored'))
              Text(
                'completion_average'.tr(
                  args: [page.summary.average ?? 'live_missing_value'.tr()],
                ),
              ),
          ],
        ),
        items: (context, rows) => LiveAcademicTable(rows: rows),
        item: (context, r) => AcademicRecordCard(record: r),
      );
}
