import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../screens/teacher/teacher_shared.dart';
import '../domain/student_record.dart';

class StudentReadCard extends StatelessWidget {
  const StudentReadCard({required this.student, super.key});
  final StudentRecord student;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppPadding.p12),
    child: TeacherCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(student.fullName, style: Theme.of(context).textTheme.titleLarge),
          Text(student.levelTag ?? 'live_missing_value'.tr()),
          const SizedBox(height: AppSize.s8),
          Text('profile_student_phone'.tr()),
          SelectableText(
            student.phone ?? 'live_missing_value'.tr(),
            textDirection: ui.TextDirection.ltr,
          ),
          const SizedBox(height: AppSize.s8),
          Text('profile_guardian_phone'.tr()),
          SelectableText(
            student.guardianPhone ?? 'live_missing_value'.tr(),
            textDirection: ui.TextDirection.ltr,
          ),
        ],
      ),
    ),
  );
}
