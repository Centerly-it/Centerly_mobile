import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/values_manager.dart';
import '../../finances/preview/finance_preview_fixture.dart';
import '../../finances/preview/finance_invoice_detail.dart';
import '../../finances/presentation/design/finance_invoice_card.dart';
import '../presentation/dashboard_unpaid_card.dart';

/// Shares the complete local finance snapshot; never queries hosted debtors.
class PreviewUnpaidStudents extends StatelessWidget {
  const PreviewUnpaidStudents({this.now, super.key});
  final DateTime? now;
  @override
  Widget build(BuildContext context) {
    final instant = now ?? DateTime.now();
    final local = CairoTime.local(instant);
    final month = DateTime(local.year, local.month);
    final ledger = FinancePreviewFixture.build(month, instant);
    final unpaid = ledger
        .dueIn(month)
        .where((i) => ledger.remaining(i) > BigInt.zero)
        .toList();
    return DashboardUnpaidCard(
      count: unpaid.map((i) => i.studentKey).toSet().length,
      onView: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text('home_unpaid_month'.tr())),
            body: ListView.separated(
              padding: const EdgeInsets.all(AppPadding.p16),
              itemCount: unpaid.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final invoice = unpaid[index];
                return FinanceInvoiceCard(
                  ledger: ledger,
                  invoice: invoice,
                  now: instant,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => FinanceInvoiceDetail(
                        ledger: ledger,
                        invoice: invoice,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
