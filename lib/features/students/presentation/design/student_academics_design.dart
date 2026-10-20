import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_section.dart';
import 'student_design.dart';
import 'student_data_table.dart';

class StudentAcademicsDesign extends StatelessWidget {
  const StudentAcademicsDesign({super.key});
  @override
  Widget build(BuildContext context) {
    final date = DateFormat.MMMMd(
      context.locale.toString(),
    ).format(DateTime(2026, 5, 10));
    return Column(
      children: [
        AppSurfaceSection(
          title: 'student_design_exams'.tr(),
          icon: const StudentAsset('20a01.svg'),
          child: StudentDataTable(
            headers: [
              'student_design_exam'.tr(),
              'student_design_date'.tr(),
              'student_design_score'.tr(),
            ],
            rows: [
              for (final score in [89, 49])
                [
                  Text(
                    'student_design_monthly_exam'.tr(),
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    date,
                    style: AppTextStyles.caption.copyWith(
                      color: ColorManager.textSecondary,
                    ),
                  ),
                  Text(
                    '$score%',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: score >= 50
                          ? ColorManager.success
                          : ColorManager.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
            ],
          ),
        ),
        const SizedBox(height: AppSize.s16),
        AppSurfaceSection(
          title: 'student_design_homework'.tr(),
          icon: const StudentAsset('460bc.svg'),
          child: StudentDataTable(
            headers: [
              'student_design_assignment'.tr(),
              'student_design_date'.tr(),
              'student_design_score'.tr(),
            ],
            rows: [
              for (var i = 0; i < 2; i++)
                [
                  Text(
                    'student_design_lesson_${i + 1}'.tr(),
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    date,
                    style: AppTextStyles.caption.copyWith(
                      color: ColorManager.textSecondary,
                    ),
                  ),
                  StudentTag(
                    label:
                        (i == 0
                                ? 'student_design_submitted'
                                : 'student_design_late')
                            .tr(),
                    positive: i == 0,
                    icon: false,
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }
}
