import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_surface_section.dart';
import '../../students/presentation/design/student_data_table.dart';
import '../../students/presentation/design/student_design.dart';
import '../../sessions/presentation/session_detail_page.dart';
import '../domain/student_attendance_record.dart';

class LiveAttendanceTable extends StatelessWidget {
  const LiveAttendanceTable({required this.rows, super.key});
  final List<StudentAttendanceRecord> rows;
  @override
  Widget build(BuildContext context) => AppSurfaceSection(
    title: 'student_design_attendance_history'.tr(),
    icon: const StudentAsset('f399a.svg'),
    child: StudentDataTable(
      headers: [
        'student_design_date'.tr(),
        'group_design_details'.tr(),
        'student_design_status'.tr(),
      ],
      rows: [
        for (final r in rows)
          [
            Column(
              children: [
                Text(r.date),
                TextButton(
                  onPressed: () => SessionDetailPage.open(context, r.sessionId),
                  child: Text('session_details_title'.tr()),
                ),
              ],
            ),
            Column(
              children: [
                Text(r.group ?? 'live_missing_value'.tr()),
                Text(
                  'detail_actor'.tr(
                    args: [r.actor ?? 'live_missing_value'.tr()],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                StudentTag(
                  label: 'attendance_${r.status}'.tr(),
                  positive: r.status == 'not_marked' || r.status == 'excused'
                      ? null
                      : r.status == 'present',
                ),
                if (r.sessionStatus == 'cancelled')
                  Text('detail_cancel_history'.tr()),
              ],
            ),
          ],
      ],
    ),
  );
}
