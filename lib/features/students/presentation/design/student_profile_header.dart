import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/values_manager.dart';
import '../../preview/student_preview_data.dart';
import 'student_design.dart';
import 'student_identity.dart';

class StudentProfileHeader extends StatelessWidget {
  const StudentProfileHeader({required this.data, super.key});
  final StudentPreviewData data;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StudentIdentity(data: data, large: true),
      const SizedBox(height: AppSize.s12),
      Wrap(
        spacing: AppSize.s12,
        runSpacing: AppSize.s8,
        children: [
          StudentTag(label: 'student_design_grade'.tr(), icon: false),
          StudentTag(
            label: 'student_design_attendance_rate_badge'.tr(
              args: ['${data.attendancePercent}%'],
            ),
            primary: true,
            icon: false,
          ),
          StudentTag(
            label:
                (data.paid
                        ? 'student_design_account_paid'
                        : 'student_design_unpaid')
                    .tr(),
            positive: data.paid,
          ),
        ],
      ),
    ],
  );
}
