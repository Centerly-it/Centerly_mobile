import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/finance_entry.dart';

class FinanceInvoiceDue extends StatelessWidget {
  const FinanceInvoiceDue({required this.invoice, super.key});
  final FinanceInvoice invoice;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(
        Icons.event_outlined,
        size: 16,
        color: ColorManager.textSecondary,
      ),
      const SizedBox(width: AppSize.s4),
      Expanded(
        child: Text(
          'finance_due_on'.tr(
            args: [
              DateFormat.MMMMd(context.locale.toString()).format(invoice.dueOn),
            ],
          ),
          style: AppTextStyles.caption,
        ),
      ),
      Icon(
        context.locale.languageCode == 'ar'
            ? Icons.chevron_left
            : Icons.chevron_right,
        color: ColorManager.primary,
        size: 20,
      ),
    ],
  );
}
