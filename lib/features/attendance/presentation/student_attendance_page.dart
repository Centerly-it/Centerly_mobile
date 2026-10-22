import 'live_attendance_table.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_reads.dart';
import '../../../core/data/read_page.dart';
import '../../../core/di/di.dart';
import '../../../shared/presentation/filtered_report_page.dart';
import '../../dashboard/presentation/dashboard_metrics.dart';
import '../domain/student_attendance_record.dart';
import 'student_attendance_card.dart';

class StudentAttendancePage extends StatelessWidget {
  const StudentAttendancePage({
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
      FilteredReportPage<StudentAttendanceRecord, StudentAttendanceSummary>(
        embedded: embedded,
        title: 'completion_attendance',
        initialDate: initialDate,
        kindKey: 'p_status',
        kinds: const {
          null: 'detail_all',
          'present': 'attendance_present',
          'absent': 'attendance_absent',
          'excused': 'attendance_excused',
          'not_marked': 'attendance_not_marked',
        },
        loader: (filters, cursor) =>
            CompletionReads(getIt<TeacherReadClient>()).page(
              TeacherRead.studentAttendance,
              params: {
                'p_id': studentId,
                ...filters,
                'p_cursor': cursor,
                'p_limit': 30,
              },
              row: StudentAttendanceRecord.fromJson,
              summary: (j) =>
                  StudentAttendanceSummary.fromJson(readMap(j['summary'])),
            ),
        identity: (r) => r.id,
        header: (context, p) => Column(
          children: [
            DashboardMetrics(
              values: {
                for (final e in p.summary.counts.entries)
                  'attendance_${e.key}': '${e.value}',
              },
            ),
            Text(
              'completion_denominator'.tr(
                args: ['${p.summary.denominator}', '${p.summary.cancelled}'],
              ),
            ),
            Text(
              'completion_attendance_ratio'.tr(
                args: [
                  p.summary.denominator == 0
                      ? 'live_missing_value'.tr()
                      : (100 *
                                p.summary.counts['present']! /
                                p.summary.denominator)
                            .toStringAsFixed(1),
                ],
              ),
            ),
          ],
        ),
        items: (context, rows) => LiveAttendanceTable(rows: rows),
        item: (context, r) => StudentAttendanceCard(record: r),
      );
}
