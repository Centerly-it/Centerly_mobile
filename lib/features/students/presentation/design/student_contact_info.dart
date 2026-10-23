import '../../domain/student_record.dart';
import 'student_contact_action.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_section.dart';
import 'student_design.dart';

class StudentContactInfo extends StatelessWidget {
  const StudentContactInfo({this.student, super.key});
  final StudentRecord? student;
  String? _phone(String who) => student == null
      ? '0123456789'
      : who == 'student_phone'
      ? student!.phone
      : student!.guardianPhone;
  @override
  Widget build(BuildContext context) => AppSurfaceSection(
    title: 'student_design_contacts'.tr(),
    icon: const StudentAsset('dadab.svg'),
    child: Column(
      children: [
        for (final who in ['student_phone', 'guardian_phone'])
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ColorManager.stroke)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'student_design_$who'.tr(),
                        style: AppTextStyles.caption.copyWith(
                          color: ColorManager.textSecondary,
                        ),
                      ),
                      SelectableText(
                        _phone(who) ?? 'live_missing_value'.tr(),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                StudentContactAction(
                  phone: _phone(who),
                  whatsapp: true,
                  preview: student == null,
                  label: 'student_design_$who'.tr(),
                ),
                const SizedBox(width: AppSize.s8),
                StudentContactAction(
                  phone: _phone(who),
                  whatsapp: false,
                  preview: student == null,
                  label: 'student_design_$who'.tr(),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
