import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_panel.dart';
import '../../domain/finance_ledger.dart';
import 'finance_design.dart';

class FinanceDebtBreakdown extends StatelessWidget {
  const FinanceDebtBreakdown({
    required this.ledger,
    required this.month,
    required this.now,
    required this.onLate,
    required this.onRemaining,
    super.key,
  });
  final FinanceLedger ledger;
  final DateTime month, now;
  final VoidCallback onLate, onRemaining;
  @override
  Widget build(BuildContext context) {
    final late = ledger.lateAmount(month, now);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in [
          ('finance_overdue', late, ColorManager.error, onLate),
          (
            'finance_not_late',
            ledger.outstanding(month) - late,
            ColorManager.warning,
            onRemaining,
          ),
        ]) ...[
          if (item.$1 != 'finance_overdue') const SizedBox(width: AppSize.s12),
          Expanded(
            child: InkWell(
              onTap: item.$4,
              child: AppSurfacePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.$1 == 'finance_overdue'
                          ? Icons.priority_high_rounded
                          : Icons.schedule_outlined,
                      size: 20,
                      color: item.$3,
                    ),
                    const SizedBox(height: AppSize.s8),
                    Text(item.$1.tr(), style: AppTextStyles.caption),
                    FinanceMoney(
                      item.$2,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: item.$3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSize.s4),
                    Text(
                      'finance_view_dues'.tr(),
                      style: AppTextStyles.caption.copyWith(
                        color: ColorManager.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
