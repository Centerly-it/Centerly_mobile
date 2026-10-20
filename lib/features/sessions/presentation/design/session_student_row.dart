import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/session_design_data.dart';
import 'session_design.dart';

class SessionStudentRow extends StatelessWidget {
  const SessionStudentRow({required this.student, super.key});
  final SessionStudentData student;
  @override
  Widget build(BuildContext context) {
    final present = student.status == 'present',
        absent = student.status == 'absent';
    final color = present
        ? SessionDesign.green
        : absent
        ? SessionDesign.red
        : SessionDesign.muted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: AppSize.s16,
            backgroundImage: AssetImage('${SessionDesign.assets}04ab7.png'),
          ),
          const SizedBox(width: AppSize.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: SessionDesign.text,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSize.s4),
                Text(
                  student.group,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: SessionDesign.muted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSize.s8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p8,
              vertical: AppPadding.p4,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              border: Border.all(
                color: color.withValues(alpha: 0.22),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.r16),
            ),
            child: Text(
              'attendance_${student.status}'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
