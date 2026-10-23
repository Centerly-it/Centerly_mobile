import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:centrally/core/widgets/app_surface_section.dart';
import 'package:centrally/features/students/domain/student_record.dart';
import 'package:centrally/features/students/presentation/design/student_contact_info.dart';
import 'package:centrally/models/centerly_models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StudentInfoTab extends StatelessWidget {
  const StudentInfoTab({required this.student, super.key});
  final Student student;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppPadding.p16),
    children: [
      StudentContactInfo(
        student: StudentRecord(
          id: student.id,
          fullName: student.name,
          createdAt: student.createdAt,
          phone: student.phone.isEmpty ? null : student.phone,
          guardianPhone: student.guardianPhone.isEmpty
              ? null
              : student.guardianPhone,
          levelTag: student.levelTag,
        ),
      ),
      const SizedBox(height: AppSize.s16),
      AppSurfaceSection(
        title: StringsManager.profileNotesTitle.tr(),
        icon: const Icon(Icons.assignment_outlined),
        child: Text(student.teacherNote ?? 'live_missing_value'.tr()),
      ),
    ],
  );
}
