import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/money_egp.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../screens/teacher/teacher_shared.dart';

class DashboardPaymentProgress extends StatelessWidget {
  const DashboardPaymentProgress({
    required this.invoiced,
    required this.outstanding,
    super.key,
  });
  final String invoiced, outstanding;

  @override
  Widget build(BuildContext context) {
    final total = MoneyEgp.parse(invoiced).minorUnits;
    final remaining = MoneyEgp.parse(outstanding).minorUnits;
    // Same invoice cohort for numerator/denominator; monthly receipts may include
    // invoices from earlier months and must not be used for this percentage.
    final net = total - remaining;
    final paid = net < BigInt.zero ? BigInt.zero : (net > total ? total : net);
    final value = total <= BigInt.zero
        ? 0.0
        : ((paid * BigInt.from(10000)) ~/ total).toInt() / 10000;
    final percent = NumberFormat.percentPattern(
      context.locale.toString(),
    ).format(value);
    return TeacherCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: AppSize.s12,
            children: [
              Text(
                'dashboard_payment_progress'.tr(),
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                percent,
                style: AppTextStyles.titleMedium.copyWith(
                  color: ColorManager.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSize.s12),
          LinearProgressIndicator(
            value: value,
            minHeight: AppSize.s10,
            borderRadius: BorderRadius.circular(AppRadius.circular),
            color: ColorManager.success,
            backgroundColor: ColorManager.primaryBright,
            semanticsLabel: 'dashboard_payment_progress'.tr(),
          ),
        ],
      ),
    );
  }
}
