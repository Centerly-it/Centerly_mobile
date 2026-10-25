import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/paged_read_body.dart';
import '../../../core/theme/values_manager.dart';
import '../data/finance_repository.dart';
import '../domain/finance_movements_summary.dart';
import 'design/finance_design.dart';
import 'live_invoice_detail.dart';
import 'live_receipt_card.dart';

class LiveMovementBody extends StatelessWidget {
  const LiveMovementBody({
    required this.repository,
    required this.onReturn,
    this.leading,
    super.key,
  });
  final Widget? leading;
  final FinanceRepository repository;
  final VoidCallback onReturn;
  @override
  Widget build(BuildContext context) =>
      PagedReadBody<Map<String, dynamic>, FinanceMovementsSummary>(
        leading: leading,
        header: (_, p) => Column(
          children: [
            Text(
              'finance_filtered_net'.tr(
                args: ['${p.total}', financeMoney(p.summary.net)],
              ),
            ),
            if (!FinanceRepository.movementFilters)
              Text('finance_live_filters'.tr()),
            const SizedBox(height: AppSize.s8),
          ],
        ),
        item: (context, r) => LiveReceiptCard(
          row: r,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LiveInvoiceDetail(
                  repository: repository,
                  id: r['invoice_id'] as String,
                ),
              ),
            );
            if (context.mounted) onReturn();
          },
        ),
      );
}
