import '../../domain/student_record.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../preview/student_preview_data.dart';

class StudentIdentity extends StatelessWidget {
  const StudentIdentity({
    this.data,
    this.record,
    this.large = false,
    super.key,
  });
  final StudentPreviewData? data;
  final StudentRecord? record;
  final bool large;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Image.asset(
        'assets/figma/sessions/04ab7.png',
        width: large ? 56 : 32,
        height: large ? 56 : 32,
      ),
      SizedBox(width: large ? AppSize.s12 : AppSize.s8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record?.fullName ?? data!.name,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: large ? FontWeight.bold : FontWeight.normal,
                height: 1.5,
              ),
            ),
            Text(
              record?.levelTag ??
                  (data == null ? 'live_missing_value'.tr() : data!.groupName),
              style: (large ? AppTextStyles.caption : AppTextStyles.bodyMedium)
                  .copyWith(
                    color: ColorManager.textSecondary,
                    fontWeight: large ? FontWeight.normal : FontWeight.w300,
                  ),
            ),
          ],
        ),
      ),
    ],
  );
}
