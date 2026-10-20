import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/format/cairo_time.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/session_design_data.dart';
import 'session_design.dart';

class SessionInfoPanel extends StatelessWidget {
  const SessionInfoPanel({required this.data, super.key});
  final SessionDesignData data;
  @override
  Widget build(BuildContext context) => SessionPanel(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppPadding.p8),
          decoration: BoxDecoration(
            color: ColorManager.primaryBright,
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          child: const SessionAsset('7b2bc.svg'),
        ),
        const SizedBox(width: AppSize.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${data.group} - ${data.subject}  ',
                      style: AppTextStyles.titleMedium,
                    ),
                    TextSpan(
                      text: data.grade,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: ColorManager.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSize.s12),
              Row(
                children: [
                  const SessionAsset('2ec16.svg'),
                  const SizedBox(width: AppSize.s8),
                  Expanded(
                    child: Text(
                      CairoTime.range(
                        data.start,
                        data.end,
                        context.locale.toString(),
                      ),
                      textAlign: TextAlign.start,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSize.s8),
              Row(
                children: [
                  const SessionAsset('b1b35.svg'),
                  const SizedBox(width: AppSize.s8),
                  Expanded(
                    child: Text(
                      DateFormat.yMMMMEEEEd(
                        context.locale.toString(),
                      ).format(data.date),
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
