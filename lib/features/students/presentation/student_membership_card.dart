import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../domain/student_membership.dart';

class StudentMembershipCard extends StatelessWidget {
  const StudentMembershipCard({required this.row, super.key});
  final StudentMembership row;
  @override
  Widget build(BuildContext context) => TeacherCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(row.groupName, style: Theme.of(context).textTheme.titleMedium),
        Text('${row.subject} · ${row.grade}'),
        Text('completion_${row.status}'.tr()),
        Text(
          'completion_joined'.tr(
            args: [CairoTime.date(CairoTime.local(row.joinedAt))],
          ),
        ),
        if (row.leftAt != null)
          Text(
            'completion_left'.tr(
              args: [CairoTime.date(CairoTime.local(row.leftAt!))],
            ),
          ),
        if (row.archivedAt != null) Text('completion_archived_group'.tr()),
      ],
    ),
  );
}
