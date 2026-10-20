import 'finance_dues_filters.dart';
import '../presentation/design/finance_design.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_search_empty.dart';
import '../domain/finance_entry.dart';
import '../domain/finance_ledger.dart';
import '../presentation/design/finance_invoice_card.dart';

class FinanceDuesList extends StatefulWidget {
  const FinanceDuesList({
    required this.ledger,
    required this.month,
    required this.now,
    required this.onInvoice,
    this.initialStatus = 'all',
    super.key,
  });
  final FinanceLedger ledger;
  final DateTime month, now;
  final String initialStatus;
  final ValueChanged<FinanceInvoice> onInvoice;
  @override
  State<FinanceDuesList> createState() => _FinanceDuesListState();
}

class _FinanceDuesListState extends State<FinanceDuesList> {
  late String _status = widget.initialStatus;
  String _query = '';
  bool _matches(FinanceInvoice i) {
    final left = widget.ledger.remaining(i), paid = widget.ledger.paid(i);
    final late = widget.ledger.overdue(i, widget.now);
    return '${i.studentKey.tr()} ${i.id}'.toLowerCase().contains(
          _query.toLowerCase(),
        ) &&
        switch (_status) {
          'overdue' => late,
          'partial' => paid > BigInt.zero && left > BigInt.zero,
          'paid' => left == BigInt.zero,
          'not_late' => !late && left > BigInt.zero,
          _ => true,
        };
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.ledger.dueIn(widget.month).where(_matches).toList()
      ..sort((a, b) => a.dueOn.compareTo(b.dueOn));
    return ListView(
      padding: const EdgeInsets.all(AppPadding.p16),
      children: [
        FinanceDuesFilters(
          selectedStatus: _status,
          onQuery: (value) => setState(() => _query = value),
          onStatus: (value) => setState(() => _status = value),
        ),
        const SizedBox(height: AppSize.s12),
        Text(
          'finance_dues_result'.tr(
            args: [
              '${rows.length}',
              financeMoney(
                rows.fold(
                  BigInt.zero,
                  (total, i) => total + widget.ledger.remaining(i),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSize.s16),
        if (rows.isEmpty) AppSearchEmpty(title: 'finance_no_dues'.tr()),
        for (final invoice in rows)
          FinanceInvoiceCard(
            invoice: invoice,
            ledger: widget.ledger,
            now: widget.now,
            onTap: () => widget.onInvoice(invoice),
          ),
      ],
    );
  }
}
