import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/widgets/app_surface_panel.dart';
import '../domain/finance_record.dart';

class FinanceRecordCard extends StatelessWidget {
  const FinanceRecordCard({required this.record, super.key});
  final FinanceRecord record;
  @override
  Widget build(BuildContext context) {
    final r = record;
    return AppSurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(r.student, style: Theme.of(context).textTheme.titleMedium),
          Text(
            'completion_money'.tr(args: [(r.signedAmount ?? r.amount).decimal]),
          ),
          if (r.status != null) Text('completion_invoice_${r.status}'.tr()),
          if (r.dueOn != null) Text('completion_due'.tr(args: [r.dueOn!])),
          if (r.paid != null)
            Text('completion_paid_value'.tr(args: [r.paid!.decimal])),
          if (r.outstanding != null)
            Text(
              'completion_outstanding_value'.tr(args: [r.outstanding!.decimal]),
            ),
          if (r.collectedAt != null)
            Text(
              '${CairoTime.date(CairoTime.local(r.collectedAt!))} ${CairoTime.time(r.collectedAt!, context.locale.languageCode)}',
            ),
          if (r.collector != null)
            Text('detail_actor'.tr(args: [r.collector!])),
          if (r.method != null) Text('completion_method_${r.method}'.tr()),
          if (r.reversalOf != null) Text('payment_correction_label'.tr()),
          if (r.reason != null) Text(r.reason!),
        ],
      ),
    );
  }
}
