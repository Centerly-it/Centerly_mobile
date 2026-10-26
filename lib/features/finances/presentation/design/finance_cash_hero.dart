import 'finance_card_rings.dart';
import 'finance_credit_card_content.dart';
import '../../domain/finance_overview_data.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/finance_ledger.dart';

class FinanceCashHero extends StatelessWidget {
  const FinanceCashHero({
    this.ledger,
    required this.month,
    this.summary,
    super.key,
  });
  final FinanceLedger? ledger;
  final FinanceOverviewData? summary;
  final DateTime month;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadius.r24),
      boxShadow: [
        BoxShadow(
          color: ColorManager.primaryDark.withAlpha(36),
          blurRadius: AppSize.s20,
          offset: const Offset(0, AppSize.s8),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r24),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              ColorManager.primaryDark,
              ColorManager.primary,
              ColorManager.primaryDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            const PositionedDirectional(
              end: -AppSize.s80,
              top: -AppSize.s80,
              child: ExcludeSemantics(child: FinanceCardRings()),
            ),
            FinanceCreditCardContent(
              amount: summary?.net ?? ledger!.net(month),
              month: month,
            ),
          ],
        ),
      ),
    ),
  );
}
