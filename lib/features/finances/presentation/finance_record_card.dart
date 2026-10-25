import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_info_row.dart';
import '../../../core/widgets/app_surface_panel.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../domain/finance_record.dart';
import 'design/finance_design.dart';
import 'finance_amount_summary.dart';
import 'live_receipt_card.dart';

class FinanceRecordCard extends StatelessWidget {
  const FinanceRecordCard({required this.record, super.key});
  final FinanceRecord record;
  @override
  Widget build(BuildContext context) {
    final r = record;
    if (r.status == null && r.collectedAt != null) {
      return LiveReceiptCard(
        row: {
          'student_name': r.student,
          'signed_amount_egp': (r.signedAmount ?? r.amount).decimal,
          'collected_by_name': r.collector,
          'method': r.method,
          'collected_at': r.collectedAt!.toIso8601String(),
          'reversal_of': r.reversalOf,
          'reason': r.reason,
        },
      );
    }
    return AppSurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(r.student, style: AppTextStyles.titleMedium),
          if (r.status != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FinancePill('completion_invoice_${r.status}'.tr()),
            ),
          const SizedBox(height: AppSize.s12),
          if (r.paid != null && r.outstanding != null)
            FinanceAmountSummary(
              amount: r.amount.minorUnits,
              paid: r.paid!.minorUnits,
              outstanding: r.outstanding!.minorUnits,
            )
          else
            FinanceMoney((r.signedAmount ?? r.amount).minorUnits),
          if (r.dueOn != null)
            AppInfoRow(label: 'ui_due_date'.tr(), value: r.dueOn!),
          if (r.collector != null)
            AppInfoRow(label: 'finance_actor'.tr(), value: r.collector!),
          if (r.method != null)
            AppInfoRow(
              label: 'finance_method'.tr(),
              value: 'completion_method_${r.method}'.tr(),
            ),
          if (r.reason != null)
            AppInfoRow(label: 'ui_reason'.tr(), value: r.reason!),
        ],
      ),
    );
  }
}
