import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';

class AttendanceHistoryNotice extends StatelessWidget {
  const AttendanceHistoryNotice({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppPadding.p8),
    decoration: BoxDecoration(
      color: ColorManager.grey200,
      borderRadius: BorderRadius.circular(AppRadius.r8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.event_busy_outlined,
          size: AppSize.s16,
          color: ColorManager.textSecondary,
        ),
        const SizedBox(width: AppSize.s8),
        Expanded(
          child: Text(
            'detail_cancel_history'.tr(),
            style: AppTextStyles.caption,
          ),
        ),
      ],
    ),
  );
}
