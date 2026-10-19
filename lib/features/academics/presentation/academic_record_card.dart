import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../domain/academic_record.dart';

class AcademicRecordCard extends StatelessWidget {
  const AcademicRecordCard({required this.record, super.key});
  final AcademicRecord record;
  @override
  Widget build(BuildContext context) {
    final r = record;
    return TeacherCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(r.title, style: Theme.of(context).textTheme.titleMedium),
          Text(r.date),
          Text(
            r.score == null
                ? (r.status == null
                      ? 'live_missing_value'.tr()
                      : 'completion_${r.status}'.tr())
                : '${r.score}%',
          ),
          if (r.group != null) Text(r.group!),
          Text('detail_actor'.tr(args: [r.actor ?? 'live_missing_value'.tr()])),
        ],
      ),
    );
  }
}
