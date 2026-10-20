import 'finance_invoice_summary.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_surface_panel.dart';
import '../domain/finance_entry.dart';
import '../domain/finance_ledger.dart';
import '../presentation/design/finance_movement_card.dart';
import 'finance_movement_detail.dart';

class FinanceInvoiceDetail extends StatelessWidget {
  const FinanceInvoiceDetail({
    required this.ledger,
    required this.invoice,
    super.key,
  });
  final FinanceLedger ledger;
  final FinanceInvoice invoice;
  @override
  Widget build(BuildContext context) {
    final movements = ledger.historyFor(invoice.id).toList()
      ..sort((a, b) => b.at.compareTo(a.at));
    return Scaffold(
      backgroundColor: ColorManager.canvas,
      appBar: AppBar(
        title: Text('finance_invoice_title'.tr(args: [invoice.id])),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppPadding.p16),
          children: [
            FinanceInvoiceSummary(ledger: ledger, invoice: invoice),
            const SizedBox(height: AppSize.s24),
            Text(
              'finance_invoice_movements'.tr(),
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSize.s12),
            if (movements.isEmpty)
              AppSurfacePanel(
                child: Text('finance_invoice_no_collection'.tr()),
              ),
            for (final movement in movements)
              FinanceMovementCard(
                movement: movement,
                invoice: invoice,
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) =>
                      FinanceMovementDetail(ledger: ledger, movement: movement),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
