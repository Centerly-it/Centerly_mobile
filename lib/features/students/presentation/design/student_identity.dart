import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../preview/student_preview_data.dart';

class StudentIdentity extends StatelessWidget {
  const StudentIdentity({required this.data, this.large = false, super.key});
  final StudentPreviewData data;
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
              data.name,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: large ? FontWeight.bold : FontWeight.normal,
                height: 1.5,
              ),
            ),
            Text(
              data.groupName,
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
