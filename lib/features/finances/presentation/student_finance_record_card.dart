import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../data/finance_repository.dart';
import '../domain/finance_entry.dart';
import '../domain/finance_record.dart';
import 'design/finance_invoice_card.dart';
import 'finance_record_card.dart';
import 'live_invoice_detail.dart';

class StudentFinanceRecordCard extends StatelessWidget {
  const StudentFinanceRecordCard({
    required this.record,
    required this.syncedAt,
    required this.repository,
    super.key,
  });
  final FinanceRecord record;
  final DateTime syncedAt;
  final FinanceRepository repository;
  @override
  Widget build(BuildContext context) {
    final r = record, date = CairoTime.local(syncedAt);
    void open() => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LiveInvoiceDetail(
          repository: repository,
          id: r.status == null ? r.invoiceId! : r.id,
        ),
      ),
    );
    if (r.status == null) {
      return InkWell(
        onTap: r.invoiceId == null ? null : open,
        child: FinanceRecordCard(record: r),
      );
    }
    return FinanceInvoiceCard(
      invoice: FinanceInvoice(
        id: r.id,
        studentKey: r.student,
        groupKey: r.group ?? '',
        amount: r.amount.minorUnits,
        dueOn: DateTime.parse(r.dueOn!),
        voided: r.status == 'void',
        localized: false,
      ),
      now: syncedAt,
      asOfDate: DateTime(date.year, date.month, date.day),
      paidAmount: r.paid!.minorUnits,
      remainingAmount: r.outstanding!.minorUnits,
      onTap: open,
    );
  }
}
