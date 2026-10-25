import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_section.dart';
import '../../preview/student_preview_data.dart';
import 'student_design.dart';

class StudentNotesInfo extends StatelessWidget {
  const StudentNotesInfo({required this.data, required this.onEdit, super.key});
  final StudentPreviewData data;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) => AppSurfaceSection(
    title: 'student_design_teacher_notes'.tr(),
    icon: const StudentAsset('e90e0.svg'),
    child: Container(
      padding: const EdgeInsets.all(AppPadding.p12),
      decoration: BoxDecoration(
        color: ColorManager.grey200,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            data.note,
            style: AppTextStyles.caption.copyWith(height: 20 / 12),
          ),
          const SizedBox(height: AppSize.s12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
                side: const BorderSide(color: ColorManager.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const StudentAsset('083ac.svg'),
                  const SizedBox(width: AppSize.s8),
                  Text(
                    'student_design_edit_note'.tr(),
                    style: AppTextStyles.caption.copyWith(
                      color: ColorManager.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
