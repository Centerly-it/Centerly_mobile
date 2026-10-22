import '../../domain/student_record.dart';
import '../../../../core/utils/contact_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_section.dart';
import 'student_design.dart';

class StudentContactInfo extends StatelessWidget {
  const StudentContactInfo({this.student, super.key});
  final StudentRecord? student;
  Future<void> _previewContact(BuildContext context, String label) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(label),
          content: const SelectableText('0123456789'),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: '0123456789'));
                Navigator.of(context).pop();
              },
              child: Text('student_design_copy_phone'.tr()),
            ),
          ],
        ),
      );
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
                IconButton(
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    fixedSize: const Size(44, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  tooltip: 'student_design_whatsapp'.tr(),
                  onPressed: student == null
                      ? () =>
                            _previewContact(context, 'student_design_$who'.tr())
                      : _phone(who) == null
                      ? null
                      : () =>
                            openContact(context, _phone(who)!, whatsapp: true),
                  icon: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorManager.successBorder),
                    ),
                    child: const StudentAsset('f921f.svg'),
                  ),
                ),
                const SizedBox(width: AppSize.s8),
                IconButton(
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    fixedSize: const Size(44, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  tooltip: 'student_design_call'.tr(),
                  onPressed: student == null
                      ? () =>
                            _previewContact(context, 'student_design_$who'.tr())
                      : _phone(who) == null
                      ? null
                      : () =>
                            openContact(context, _phone(who)!, whatsapp: false),
                  icon: const StudentAsset('853f1.svg'),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
