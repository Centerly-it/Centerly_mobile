import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/finance_ledger.dart';
import 'finance_design.dart';

class FinanceCashHero extends StatelessWidget {
  const FinanceCashHero({required this.ledger, required this.month, super.key});
  final FinanceLedger ledger;
  final DateTime month;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppPadding.p20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [ColorManager.primary, ColorManager.primaryDark],
      ),
      borderRadius: BorderRadius.circular(AppRadius.r16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'finance_period_net'.tr(),
                style: AppTextStyles.titleSmall.copyWith(
                  color: ColorManager.white,
                ),
              ),
            ),
            IconButton(
              tooltip: 'finance_net_explanation'.tr(),
              icon: const Icon(
                Icons.info_outline,
                color: ColorManager.white,
                size: 20,
              ),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('finance_period_net'.tr()),
                  content: Text('finance_cash_explanation'.tr()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('finance_understood'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        FinanceMoney(
          ledger.net(month),
          style: AppTextStyles.displayLarge.copyWith(
            color: ColorManager.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSize.s16),
        const Divider(color: ColorManager.primaryLight),
        const SizedBox(height: AppSize.s8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in [
              ('finance_gross', ledger.gross(month)),
              ('finance_corrections', ledger.corrections(month)),
            ])
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1.tr(),
                      style: AppTextStyles.caption.copyWith(
                        color: ColorManager.white,
                      ),
                    ),
                    const SizedBox(height: AppSize.s4),
                    FinanceMoney(
                      item.$2,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: ColorManager.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
