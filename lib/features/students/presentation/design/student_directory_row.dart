import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../preview/student_preview_data.dart';
import 'student_design.dart';
import 'student_identity.dart';

class StudentDirectoryRow extends StatelessWidget {
  const StudentDirectoryRow({
    required this.data,
    required this.onTap,
    super.key,
  });
  final StudentPreviewData data;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(12) > 16;
    final tag = StudentTag(
      label: (data.paid ? 'student_design_paid' : 'student_design_unpaid').tr(),
      positive: data.paid,
    );
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppPadding.p12,
              horizontal: AppPadding.p4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: StudentIdentity(data: data)),
                    const SizedBox(width: AppSize.s8),
                    if (!large) tag,
                    const SizedBox(width: AppSize.s12),
                    RotatedBox(
                      quarterTurns: context.locale.languageCode == 'ar' ? 0 : 2,
                      child: const StudentAsset('23005.svg'),
                    ),
                  ],
                ),
                if (large)
                  Align(alignment: AlignmentDirectional.centerEnd, child: tag),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: ColorManager.stroke),
        const SizedBox(height: AppSize.s8),
      ],
    );
  }
}
