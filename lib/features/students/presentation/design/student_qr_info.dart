import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_section.dart';
import '../../preview/student_preview_data.dart';
import 'student_design.dart';

class StudentQrInfo extends StatelessWidget {
  const StudentQrInfo({required this.data, super.key});
  final StudentPreviewData data;
  @override
  Widget build(BuildContext context) => AppSurfaceSection(
    title: 'student_design_qr'.tr(),
    icon: const StudentAsset('dbef8.svg'),
    child: Row(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ColorManager.primaryBright,
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          child: Image.asset(
            'assets/figma/students/d6b26.png',
            width: 57.002,
            height: 58.196,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: AppSize.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'student_design_qr_description'.tr(),
                style: AppTextStyles.caption.copyWith(
                  color: ColorManager.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSize.s8),
              Container(
                padding: const EdgeInsets.all(AppPadding.p8),
                decoration: BoxDecoration(
                  color: ColorManager.grey200,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Text(
                  'student_design_identifier'.tr(args: ['#${48922 + data.id}']),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
