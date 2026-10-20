import 'finance_secretary_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/widgets/app_surface_section.dart';
import '../../domain/finance_ledger.dart';

class FinanceSecretariesSummary extends StatelessWidget {
  const FinanceSecretariesSummary({
    required this.ledger,
    required this.month,
    required this.onActor,
    super.key,
  });
  final FinanceLedger ledger;
  final DateTime month;
  final ValueChanged<String> onActor;
  @override
  Widget build(BuildContext context) => AppSurfaceSection(
    title: 'finance_by_secretary'.tr(),
    icon: const Icon(
      Icons.badge_outlined,
      size: 18,
      color: ColorManager.primary,
    ),
    child: Column(
      children: [
        for (final actor
            in ledger.receivedIn(month).map((m) => m.actor).toSet())
          FinanceSecretaryRow(
            ledger: ledger,
            month: month,
            actor: actor,
            onTap: () => onActor(actor),
          ),
        if (ledger.receivedIn(month).isEmpty)
          Text('finance_no_movements'.tr(), style: AppTextStyles.bodyMedium),
      ],
    ),
  );
}
