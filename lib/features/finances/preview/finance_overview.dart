import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_surface_panel.dart';
import '../domain/finance_ledger.dart';
import '../presentation/design/finance_cash_hero.dart';
import '../presentation/design/finance_cohort_summary.dart';
import '../presentation/design/finance_debt_breakdown.dart';
import '../presentation/design/finance_secretaries_summary.dart';
import '../presentation/design/finance_methods_summary.dart';
import 'finance_calculator.dart';

class FinanceOverview extends StatelessWidget {
  const FinanceOverview({
    required this.ledger,
    required this.month,
    required this.now,
    required this.onDues,
    required this.onActor,
    super.key,
  });
  final FinanceLedger ledger;
  final DateTime month, now;
  final ValueChanged<String> onDues, onActor;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppPadding.p16),
    children: [
      FinanceCashHero(ledger: ledger, month: month),
      const SizedBox(height: AppSize.s16),
      FinanceCohortSummary(ledger: ledger, month: month),
      const SizedBox(height: AppSize.s16),
      FinanceDebtBreakdown(
        ledger: ledger,
        month: month,
        now: now,
        onLate: () => onDues('overdue'),
        onRemaining: () => onDues('not_late'),
      ),
      const SizedBox(height: AppSize.s16),
      FinanceSecretariesSummary(ledger: ledger, month: month, onActor: onActor),
      const SizedBox(height: AppSize.s16),
      FinanceMethodsSummary(ledger: ledger, month: month),
      const SizedBox(height: AppSize.s16),
      InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                FinanceCalculator(ledger: ledger, month: month, now: now),
          ),
        ),
        child: AppSurfacePanel(
          child: Row(
            children: [
              const Icon(
                Icons.calculate_outlined,
                color: ColorManager.primary,
                size: 32,
              ),
              const SizedBox(width: AppSize.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'finance_calculator'.tr(),
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(
                      'finance_calculator_hint'.tr(),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Icon(
                context.locale.languageCode == 'ar'
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: ColorManager.primary,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
