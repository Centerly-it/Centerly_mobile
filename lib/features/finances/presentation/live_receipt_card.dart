import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/format/money_egp.dart';
import '../../../core/widgets/app_surface_panel.dart';
import 'design/finance_design.dart';

/// Attribution is supplied by the server, including original and correcting actors.
class LiveReceiptCard extends StatelessWidget {
  const LiveReceiptCard({required this.row, this.onTap, super.key});
  final Map<String, dynamic> row;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: AppSurfacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (row['student_name'] != null) Text(row['student_name'] as String),
          FinanceMoney(MoneyEgp.parse(row['signed_amount_egp']).minorUnits),
          Text(
            'detail_actor'.tr(
              args: [
                row['collected_by_name'] as String? ??
                    'completion_missing'.tr(),
              ],
            ),
          ),
          Text('completion_method_${row['method']}'.tr()),
          Text(
            '${CairoTime.date(CairoTime.local(DateTime.parse(row['collected_at'] as String)))} · ${CairoTime.time(DateTime.parse(row['collected_at'] as String), context.locale.toString())}',
          ),
          if (row['reversal_of'] != null) ...[
            Text('payment_correction_label'.tr()),
            if (row['original_collected_by_name'] != null)
              Text(
                'finance_original_collector'.tr(
                  args: [row['original_collected_by_name'] as String],
                ),
              ),
          ],
          if (row['correction_receipt_number'] != null)
            Text('payment_corrected_label'.tr()),
          if (row['reason'] != null) Text(row['reason'] as String),
        ],
      ),
    ),
  );
}
