import '../../domain/finance_overview_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_panel.dart';
import '../../domain/finance_ledger.dart';
import 'finance_design.dart';

class FinanceMethodsSummary extends StatelessWidget {
  const FinanceMethodsSummary({
    this.ledger,
    this.summary,
    required this.month,
    super.key,
  });
  final FinanceLedger? ledger;
  final FinanceOverviewData? summary;
  final DateTime month;
  @override
  Widget build(BuildContext context) => AppSurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('finance_by_method'.tr(), style: AppTextStyles.bodySemiBold),
        const SizedBox(height: AppSize.s12),
        Wrap(
          spacing: AppSize.s16,
          runSpacing: AppSize.s12,
          children: [
            for (final method in ['cash', 'transfer', 'other'])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'completion_method_$method'.tr(),
                    style: AppTextStyles.caption,
                  ),
                  FinanceMoney(
                    summary != null
                        ? (summary!.methods[method] ?? BigInt.zero)
                        : ledger!
                              .receivedIn(month)
                              .where((m) => m.method == method)
                              .fold(
                                BigInt.zero,
                                (sum, m) => sum + m.signedAmount,
                              ),
                    style: AppTextStyles.titleSmall.copyWith(
                      color: ColorManager.primaryDark,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    ),
  );
}
