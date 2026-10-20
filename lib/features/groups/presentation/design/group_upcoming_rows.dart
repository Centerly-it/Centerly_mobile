import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/format/cairo_time.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'group_design.dart';
import '../../preview/group_preview_data.dart';

class GroupUpcomingRows extends StatelessWidget {
  const GroupUpcomingRows({required this.data, this.count = 2, super.key});
  final GroupPreviewData data;
  final int count;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < count; i++)
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: GroupDesign.stroke)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat.yMMMMEEEEd(
                    context.locale.toString(),
                  ).format(DateTime(2026, 5, 26 + i * 3)),
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(width: AppSize.s8),
              Flexible(
                child: Text(
                  CairoTime.range(
                    DateTime.utc(2026, 5, 26 + i * 3, data.hour - 3),
                    DateTime.utc(2026, 5, 26 + i * 3, data.hour - 2, 30),
                    context.locale.toString(),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: ColorManager.grey500,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
