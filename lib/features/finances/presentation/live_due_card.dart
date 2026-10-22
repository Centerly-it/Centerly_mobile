import 'package:flutter/material.dart';
import '../data/finance_repository.dart';
import '../domain/finance_due.dart';
import 'design/finance_invoice_card.dart';
import 'live_invoice_detail.dart';

class LiveDueCard extends StatelessWidget {
  const LiveDueCard({
    required this.row,
    required this.asOf,
    required this.repository,
    required this.onReturn,
    super.key,
  });
  final FinanceDue row;
  final DateTime asOf;
  final FinanceRepository repository;
  final VoidCallback onReturn;
  @override
  Widget build(BuildContext context) => FinanceInvoiceCard(
    invoice: row.design,
    now: DateTime.now(),
    paidAmount: row.paid,
    remainingAmount: row.outstanding,
    asOfDate: asOf,
    onTap: () async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LiveInvoiceDetail(repository: repository, id: row.id),
        ),
      );
      if (context.mounted) onReturn();
    },
  );
}
