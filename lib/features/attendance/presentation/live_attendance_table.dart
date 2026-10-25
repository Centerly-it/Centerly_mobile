import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_surface_section.dart';
import '../../students/presentation/design/student_design.dart';
import '../domain/student_attendance_record.dart';
import 'attendance_history_row.dart';

class LiveAttendanceTable extends StatelessWidget {
  const LiveAttendanceTable({required this.rows, super.key});
  final List<StudentAttendanceRecord> rows;
  @override
  Widget build(BuildContext context) => AppSurfaceSection(
    title: 'student_design_attendance_history'.tr(),
    icon: const StudentAsset('f399a.svg'),
    child: Column(
      children: [for (final row in rows) AttendanceHistoryRow(record: row)],
    ),
  );
}
