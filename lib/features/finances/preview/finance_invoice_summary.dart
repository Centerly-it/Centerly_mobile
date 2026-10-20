import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_surface_panel.dart';
import '../domain/finance_entry.dart';
import '../domain/finance_ledger.dart';
import '../presentation/design/finance_design.dart';

class FinanceInvoiceSummary extends StatelessWidget {
  const FinanceInvoiceSummary({
    required this.ledger,
    required this.invoice,
    super.key,
  });
  final FinanceLedger ledger;
  final FinanceInvoice invoice;
  @override
  Widget build(BuildContext context) => AppSurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(invoice.studentKey.tr(), style: AppTextStyles.headlineSmall),
        Text(invoice.groupKey.tr(), style: AppTextStyles.caption),
        const SizedBox(height: AppSize.s16),
        for (final item in [
          ('finance_invoice_total', invoice.amount),
          ('finance_paid_against', ledger.paid(invoice)),
          ('finance_outstanding', ledger.remaining(invoice)),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p4),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: AppSize.s16,
              children: [
                Text(item.$1.tr()),
                Text(
                  financeMoney(item.$2, exact: true),
                  style: AppTextStyles.bodySemiBold,
                ),
              ],
            ),
          ),
        const Divider(),
        Text(
          'finance_due_on'.tr(
            args: [
              DateFormat.yMMMMd(
                context.locale.toString(),
              ).format(invoice.dueOn),
            ],
          ),
          style: AppTextStyles.bodyMedium,
        ),
        if (invoice.createdBy != null)
          Text(
            'finance_created_by'.tr(
              args: ['finance_demo_secretary_${invoice.createdBy}'.tr()],
            ),
            style: AppTextStyles.bodyMedium,
          ),
      ],
    ),
  );
}
