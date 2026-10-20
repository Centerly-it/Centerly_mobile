import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import 'session_design.dart';

class SessionDetailActions extends StatelessWidget {
  const SessionDetailActions({
    required this.onAttendance,
    required this.onCancel,
    this.cancellationReason,
    super.key,
  });
  final VoidCallback onAttendance, onCancel;
  final String? cancellationReason;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FilledButton(
        onPressed: onAttendance,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SessionAsset('d56bb.svg'),
              const SizedBox(width: AppSize.s8),
              Flexible(
                child: Text(
                  'design_open_attendance'.tr(),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: ColorManager.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSize.s16),
      if (cancellationReason == null)
        TextButton(
          onPressed: onCancel,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SessionAsset('2b2af.svg'),
              const SizedBox(width: AppSize.s8),
              Flexible(
                child: Text(
                  'session_cancel_button'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: SessionDesign.red,
                  ),
                ),
              ),
            ],
          ),
        )
      else
        SessionPanel(
          child: Text('${'status_cancelled'.tr()}: $cancellationReason'),
        ),
      const SizedBox(height: AppSize.s16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SessionAsset('01091.svg'),
          const SizedBox(width: AppSize.s8),
          Flexible(
            child: Text(
              'design_cancel_explanation'.tr(),
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    ],
  );
}
