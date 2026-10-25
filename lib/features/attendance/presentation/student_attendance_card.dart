import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../../sessions/presentation/session_detail_page.dart';
import '../domain/student_attendance_record.dart';

class StudentAttendanceCard extends StatelessWidget {
  const StudentAttendanceCard({required this.record, super.key});
  final StudentAttendanceRecord record;
  @override
  Widget build(BuildContext context) {
    final r = record;
    return TeacherCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${r.date} · ${r.group ?? 'live_missing_value'.tr()}'),
          Text('attendance_${r.status}'.tr()),
          if (r.sessionStatus == 'cancelled')
            Text('detail_cancel_history'.tr()),
          Text('detail_actor'.tr(args: [r.actor ?? 'live_missing_value'.tr()])),
          TextButton(
            onPressed: () => SessionDetailPage.open(context, r.sessionId),
            child: Text('session_details_title'.tr()),
          ),
        ],
      ),
    );
  }
}
