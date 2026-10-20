import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/finance_entry.dart';
import 'finance_design.dart';

class FinanceInvoiceAmounts extends StatelessWidget {
  const FinanceInvoiceAmounts({
    required this.invoice,
    required this.paid,
    required this.remaining,
    required this.color,
    super.key,
  });
  final FinanceInvoice invoice;
  final BigInt paid, remaining;
  final Color color;
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    spacing: AppSize.s12,
    runSpacing: AppSize.s8,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('finance_outstanding'.tr(), style: AppTextStyles.caption),
          FinanceMoney(
            remaining,
            style: AppTextStyles.headlineSmall.copyWith(color: color),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'finance_paid_value'.tr(args: [financeMoney(paid)]),
            style: AppTextStyles.caption,
          ),
          Text(
            'finance_invoice_value'.tr(args: [financeMoney(invoice.amount)]),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    ],
  );
}
