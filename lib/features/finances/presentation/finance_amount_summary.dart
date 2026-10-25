import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import 'design/finance_design.dart';

class FinanceAmountSummary extends StatelessWidget {
  const FinanceAmountSummary({
    required this.amount,
    required this.paid,
    required this.outstanding,
    super.key,
  });
  final BigInt amount, paid, outstanding;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppPadding.p16),
    decoration: BoxDecoration(
      color: ColorManager.primaryBright,
      borderRadius: BorderRadius.circular(AppRadius.r12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('finance_outstanding'.tr(), style: AppTextStyles.bodySmall),
        FinanceMoney(
          outstanding,
          style: AppTextStyles.headlineLarge.copyWith(
            color: outstanding == BigInt.zero
                ? ColorManager.success
                : ColorManager.primary,
          ),
        ),
        const SizedBox(height: AppSize.s12),
        const Divider(height: AppSize.s1),
        const SizedBox(height: AppSize.s12),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.6;
            Widget metric(String label, BigInt value) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                FinanceMoney(value),
              ],
            );
            final total = metric('finance_invoice_total'.tr(), amount);
            final settled = metric('finance_paid_against'.tr(), paid);
            return stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      total,
                      const SizedBox(height: AppSize.s12),
                      settled,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: total),
                      const SizedBox(width: AppSize.s16),
                      Expanded(child: settled),
                    ],
                  );
          },
        ),
      ],
    ),
  );
}
