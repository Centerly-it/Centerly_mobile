import 'finance_invoice_due.dart';
import 'finance_invoice_amounts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../../../core/widgets/app_surface_panel.dart';
import '../../domain/finance_entry.dart';
import '../../domain/finance_ledger.dart';
import 'finance_design.dart';

class FinanceInvoiceCard extends StatelessWidget {
  const FinanceInvoiceCard({
    required this.invoice,
    required this.ledger,
    required this.now,
    required this.onTap,
    super.key,
  });
  final FinanceInvoice invoice;
  final FinanceLedger ledger;
  final DateTime now;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final remaining = ledger.remaining(invoice), paid = ledger.paid(invoice);
    final late = ledger.overdue(invoice, now);
    final status = remaining == BigInt.zero
        ? 'paid'
        : late
        ? 'overdue'
        : paid > BigInt.zero
        ? 'partial'
        : 'not_late';
    final color = remaining == BigInt.zero
        ? ColorManager.success
        : late
        ? ColorManager.error
        : ColorManager.warning;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.p12),
      child: InkWell(
        onTap: onTap,
        child: AppSurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invoice.studentKey.tr(),
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.s8),
                  FinancePill('finance_status_$status'.tr(), color: color),
                ],
              ),
              Text(
                '${invoice.groupKey.tr()}  ·  #${invoice.id}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSize.s12),
              FinanceInvoiceAmounts(
                invoice: invoice,
                paid: paid,
                remaining: remaining,
                color: color,
              ),
              const SizedBox(height: AppSize.s12),
              FinanceInvoiceDue(invoice: invoice),
            ],
          ),
        ),
      ),
    );
  }
}
