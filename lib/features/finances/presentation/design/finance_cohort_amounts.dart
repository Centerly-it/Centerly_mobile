import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import 'finance_design.dart';

class FinanceCohortAmounts extends StatelessWidget {
  const FinanceCohortAmounts({
    required this.paid,
    required this.remaining,
    super.key,
  });
  final BigInt paid, remaining;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('finance_paid_against'.tr(), style: AppTextStyles.caption),
            FinanceMoney(
              paid,
              style: AppTextStyles.titleMedium.copyWith(
                color: ColorManager.success,
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('finance_outstanding'.tr(), style: AppTextStyles.caption),
            FinanceMoney(
              remaining,
              style: AppTextStyles.titleMedium.copyWith(
                color: ColorManager.warning,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
