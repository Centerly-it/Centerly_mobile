import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/localized_digits_formatter.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_surface_panel.dart';
import '../domain/finance_plan.dart';
import 'design/finance_design.dart';

class FinanceTargetPanel extends StatelessWidget {
  const FinanceTargetPanel({
    required this.plan,
    required this.target,
    required this.controller,
    required this.onChanged,
    super.key,
  });
  final FinancePlan plan;
  final BigInt? target;
  final TextEditingController controller;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => AppSurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('finance_target_title'.tr(), style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppSize.s12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: const [LocalizedDigitsFormatter()],
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: 'finance_target_input'.tr(),
            suffixText: 'finance_egp'.tr(),
            counterText: '',
            errorText: target == null ? 'finance_target_required'.tr() : null,
          ),
        ),
        const SizedBox(height: AppSize.s16),
        if (target != null) ...[
          Text(
            'finance_target_gap'.tr(args: [financeMoney(plan.gap)]),
            style: AppTextStyles.bodySemiBold,
          ),
          const SizedBox(height: AppSize.s12),
          Text(
            plan.perDay == null
                ? 'finance_period_ended'.tr()
                : 'finance_target_daily'.tr(
                    args: [financeMoney(plan.perDay!), '${plan.days}'],
                  ),
            style: AppTextStyles.bodyMedium,
          ),
          if (plan.beyondCurrentDues > BigInt.zero)
            Padding(
              padding: const EdgeInsets.only(top: AppPadding.p12),
              child: FinancePill(
                'finance_target_extra'.tr(
                  args: [financeMoney(plan.beyondCurrentDues)],
                ),
                color: ColorManager.warning,
              ),
            ),
        ],
      ],
    ),
  );
}
