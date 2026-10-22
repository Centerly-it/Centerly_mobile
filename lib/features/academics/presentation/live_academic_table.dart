import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_surface_section.dart';
import '../../students/presentation/design/student_data_table.dart';
import '../../students/presentation/design/student_design.dart';
import '../domain/academic_record.dart';

class LiveAcademicTable extends StatelessWidget {
  const LiveAcademicTable({required this.rows, super.key});
  final List<AcademicRecord> rows;
  @override
  Widget build(BuildContext context) => AppSurfaceSection(
    title: 'completion_academics'.tr(),
    icon: const StudentAsset('20a01.svg'),
    child: StudentDataTable(
      headers: [
        (rows.first.status == null
                ? 'student_design_exam'
                : 'student_design_assignment')
            .tr(),
        'student_design_date'.tr(),
        'student_design_score'.tr(),
      ],
      rows: [
        for (final r in rows)
          [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title),
                if (r.group != null) Text(r.group!),
                Text(
                  'detail_actor'.tr(
                    args: [r.actor ?? 'live_missing_value'.tr()],
                  ),
                ),
              ],
            ),
            Text(r.date),
            r.status == null
                ? Text(
                    r.score == null ? 'live_missing_value'.tr() : '${r.score}%',
                  )
                : StudentTag(
                    label: 'completion_${r.status}'.tr(),
                    positive: r.status == 'submitted',
                    icon: false,
                  ),
          ],
      ],
    ),
  );
}
