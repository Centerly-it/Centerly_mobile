import '../../domain/finance_overview_data.dart';
import 'finance_cohort_amounts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_section.dart';
import '../../domain/finance_ledger.dart';
import 'finance_design.dart';

class FinanceCohortSummary extends StatelessWidget {
  const FinanceCohortSummary({
    this.ledger,
    this.summary,
    required this.month,
    super.key,
  });
  final FinanceLedger? ledger;
  final FinanceOverviewData? summary;
  final DateTime month;
  @override
  Widget build(BuildContext context) {
    final total = summary?.invoiced ?? ledger!.invoiced(month),
        paid = summary?.paid ?? ledger!.paidAgainst(month);
    final percent = total == BigInt.zero
        ? 0
        : (paid * BigInt.from(100) ~/ total).toInt();
    return AppSurfaceSection(
      title: 'finance_month_dues'.tr(),
      headerSpacing: AppSize.s4,
      icon: const Icon(
        Icons.receipt_long_outlined,
        size: 18,
        color: ColorManager.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSize.s18 + AppPadding.p8 * 2 + AppSize.s12,
            ),
            child: FinanceMoney(
              total,
              style: AppTextStyles.headlineLarge.copyWith(
                color: ColorManager.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSize.s24),
          FinanceCohortAmounts(
            paid: paid,
            remaining: summary?.outstanding ?? ledger!.outstanding(month),
          ),
          const SizedBox(height: AppSize.s12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r8),
            child: LinearProgressIndicator(
              value: percent.clamp(0, 100) / 100,
              minHeight: 8,
              backgroundColor: ColorManager.grey200,
              color: ColorManager.success,
            ),
          ),
          const SizedBox(height: AppSize.s8),
          Text(
            'finance_coverage'.tr(args: ['$percent%']),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
