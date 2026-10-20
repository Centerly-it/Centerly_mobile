import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/session_design_data.dart';
import 'session_design.dart';
import 'session_time_badge.dart';

class SessionDesignCard extends StatelessWidget {
  const SessionDesignCard({required this.data, required this.onTap, super.key});
  final SessionDesignData data;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final current = data.current && data.cancellationReason == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.p8),
      child: Semantics(
        button: true,
        child: SessionPanel(
          selected: current,
          minHeight: 72,
          padding: 0,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.p12),
              child: Row(
                children: [
                  SessionTimeBadge(start: data.start, current: current),
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
                        Wrap(
                          spacing: AppSize.s8,
                          children: [
                            if (current)
                              Text(
                                'design_current_session'.tr(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: ColorManager.primary,
                                ),
                              ),
                            if (data.cancellationReason == null &&
                                (current || data.completed))
                              Text(
                                '${data.present}/${data.expected}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: SessionDesign.green,
                                ),
                              ),
                            if (data.cancellationReason != null)
                              Text(
                                'status_cancelled'.tr(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: SessionDesign.red,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: context.locale.languageCode == 'ar' ? 2 : 0,
                    child: const SessionAsset('ea117.svg'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
