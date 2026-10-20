import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/finance_ledger.dart';
import 'finance_design.dart';

class FinanceSecretaryRow extends StatelessWidget {
  const FinanceSecretaryRow({
    required this.ledger,
    required this.month,
    required this.actor,
    required this.onTap,
    super.key,
  });
  final FinanceLedger ledger;
  final DateTime month;
  final String actor;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final name = 'finance_demo_secretary_$actor'.tr();
    final rows = ledger.receivedIn(month).where((m) => m.actor == actor);
    final net = ledger.net(month, actor: actor);
    final amount = FinanceMoney(
      net,
      style: AppTextStyles.titleSmall.copyWith(
        color: net.isNegative ? ColorManager.error : ColorManager.success,
      ),
    );
    final counts = Text(
      'finance_entries_count'.tr(
        args: [
          '${rows.where((m) => !m.reversed).length}',
          '${rows.where((m) => m.reversed).length}',
        ],
      ),
      style: AppTextStyles.caption,
    );
    final avatar = CircleAvatar(
      backgroundColor: ColorManager.primaryBright,
      foregroundColor: ColorManager.primary,
      child: Text(name.substring(0, 1)),
    );
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(16) > 22;
            final title = Text(name, style: AppTextStyles.titleSmall);
            return stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          avatar,
                          const SizedBox(width: AppSize.s12),
                          Expanded(child: title),
                        ],
                      ),
                      const SizedBox(height: AppSize.s8),
                      counts,
                      const SizedBox(height: AppSize.s8),
                      amount,
                    ],
                  )
                : Row(
                    children: [
                      avatar,
                      const SizedBox(width: AppSize.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [title, counts],
                        ),
                      ),
                      const SizedBox(width: AppSize.s8),
                      Flexible(child: amount),
                      Icon(
                        context.locale.languageCode == 'ar'
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                        size: 18,
                        color: ColorManager.textSecondary,
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
