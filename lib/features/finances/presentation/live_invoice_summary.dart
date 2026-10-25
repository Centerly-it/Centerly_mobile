import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_info_row.dart';
import '../../../core/widgets/app_surface_section.dart';
import '../domain/finance_due.dart';
import 'design/finance_design.dart';
import 'finance_amount_summary.dart';

class LiveInvoiceSummary extends StatelessWidget {
  const LiveInvoiceSummary({required this.invoice, super.key});
  final FinanceDue invoice;
  @override
  Widget build(BuildContext context) => AppSurfaceSection(
    icon: const Icon(Icons.receipt_long_outlined),
    title: 'student_dues_title'.tr(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: AppSize.s12,
          runSpacing: AppSize.s8,
          children: [
            Text(invoice.student, style: AppTextStyles.titleMedium),
            FinancePill(
              'completion_invoice_${invoice.status}'.tr(),
              color: invoice.status == 'paid'
                  ? ColorManager.success
                  : ColorManager.primary,
            ),
          ],
        ),
        if (invoice.group.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppPadding.p4),
            child: Text(invoice.group, style: AppTextStyles.caption),
          ),
        const SizedBox(height: AppSize.s16),
        FinanceAmountSummary(
          amount: invoice.amount,
          paid: invoice.paid,
          outstanding: invoice.outstanding,
        ),
        const SizedBox(height: AppSize.s8),
        AppInfoRow(
          label: 'ui_due_date'.tr(),
          icon: Icons.event_outlined,
          value: DateFormat.yMMMd(
            context.locale.toString(),
          ).format(invoice.due),
        ),
        const Divider(height: AppSize.s1),
        AppInfoRow(
          label: 'ui_invoice_creator'.tr(),
          icon: Icons.person_outline,
          value: invoice.creator ?? 'completion_missing'.tr(),
        ),
      ],
    ),
  );
}
