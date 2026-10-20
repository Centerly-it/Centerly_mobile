import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/format/money_egp.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/widgets/app_surface_section.dart';
import 'student_design.dart';
import '../../preview/student_preview_data.dart';
import 'student_data_table.dart';

class StudentInvoiceHistory extends StatelessWidget {
  const StudentInvoiceHistory({required this.data, super.key});
  final StudentPreviewData data;
  @override
  Widget build(BuildContext context) {
    final unit = 'student_design_currency'.tr();
    return AppSurfaceSection(
      title: 'student_design_invoice_history'.tr(),
      icon: const StudentAsset('f399a.svg'),
      child: StudentDataTable(
        headers: [
          'student_design_invoice'.tr(),
          'student_design_amount'.tr(),
          'student_design_due_date'.tr(),
          'student_design_status'.tr(),
        ],
        rows: [
          for (final invoice in data.invoices)
            [
              Text(
                '#${invoice.number}',
                textDirection: ui.TextDirection.ltr,
                style: AppTextStyles.caption,
              ),
              Text(
                '${MoneyEgp.parse(invoice.amountEgp).groupedWholePounds} $unit',
                style: AppTextStyles.caption,
              ),
              Text(
                DateFormat.MMMMd(
                  context.locale.toString(),
                ).format(invoice.dueOn),
                style: AppTextStyles.caption.copyWith(
                  color: ColorManager.textSecondary,
                ),
              ),
              StudentTag(
                label:
                    (invoice.settled
                            ? 'student_design_invoice_paid'
                            : 'finance_status_partial')
                        .tr(),
                positive: invoice.settled,
              ),
            ],
        ],
      ),
    );
  }
}
