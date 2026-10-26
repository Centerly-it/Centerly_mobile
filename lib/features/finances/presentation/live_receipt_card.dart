import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/format/money_egp.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_info_row.dart';
import '../../../core/widgets/app_surface_panel.dart';
import 'design/finance_design.dart';

/// Attribution always comes from the server, including original/correcting actors.
class LiveReceiptCard extends StatelessWidget {
  const LiveReceiptCard({required this.row, this.onTap, super.key});
  final Map<String, dynamic> row;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    if (row['reversal_of'] != null ||
        row['correction_receipt_number'] != null ||
        row['reversed_by_payment_id'] != null) {
      return const SizedBox.shrink();
    }
    final amount = MoneyEgp.parse(row['signed_amount_egp']).minorUnits;
    final at = DateTime.parse(row['collected_at'] as String);
    return InkWell(
      onTap: onTap,
      child: AppSurfacePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: ColorManager.success,
                ),
                const SizedBox(width: AppSize.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (row['student_name'] != null)
                        Text(
                          row['student_name'] as String,
                          style: AppTextStyles.bodySemiBold,
                        ),
                      Text('ui_payment'.tr(), style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(width: AppSize.s8),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FinanceMoney(amount),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSize.s12),
            const Divider(height: AppSize.s1),
            AppInfoRow(
              label: 'finance_actor'.tr(),
              value:
                  row['collected_by_name'] as String? ??
                  'completion_missing'.tr(),
            ),
            AppInfoRow(
              label: 'finance_method'.tr(),
              value: 'completion_method_${row['method']}'.tr(),
            ),
            AppInfoRow(
              label: 'finance_recorded_at'.tr(),
              value:
                  '${CairoTime.date(CairoTime.local(at))} · ${CairoTime.time(at, context.locale.toString())}',
              valueStyle: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
