import 'finance_original_movement.dart';
import '../presentation/design/finance_detail_line.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/format/cairo_time.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../domain/finance_entry.dart';
import '../domain/finance_ledger.dart';
import '../presentation/design/finance_design.dart';

class FinanceMovementDetail extends StatelessWidget {
  const FinanceMovementDetail({
    required this.ledger,
    required this.movement,
    super.key,
  });
  final FinanceLedger ledger;
  final FinanceMovement movement;
  @override
  Widget build(BuildContext context) {
    final invoice = ledger.invoice(movement.invoiceId);
    final original = movement.reversed
        ? ledger.movement(movement.reversalOf!)
        : null;
    final reversedBy = ledger.correctionFor(movement.id);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (movement.reversed
                      ? 'finance_correction_detail'
                      : 'finance_collection_detail')
                  .tr(),
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSize.s12),
            FinanceMoney(
              movement.signedAmount,
              style: AppTextStyles.headlineLarge.copyWith(
                color: movement.reversed
                    ? ColorManager.error
                    : ColorManager.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            FinanceDetailLine('finance_student'.tr(), invoice.studentKey.tr()),
            FinanceDetailLine('finance_invoice'.tr(), '#${invoice.id}'),
            FinanceDetailLine('finance_receipt'.tr(), movement.id),
            FinanceDetailLine(
              'finance_actor'.tr(),
              'finance_demo_secretary_${movement.actor}'.tr(),
            ),
            FinanceDetailLine(
              'finance_method'.tr(),
              'completion_method_${movement.method}'.tr(),
            ),
            FinanceDetailLine(
              'finance_recorded_at'.tr(),
              '${DateFormat.yMMMMd(context.locale.toString()).format(CairoTime.local(movement.at))} ${CairoTime.time(movement.at, context.locale.toString())}',
            ),
            if (original != null)
              FinanceOriginalMovement(original: original, movement: movement),
            if (reversedBy != null)
              FinancePill(
                'finance_reversed_notice'.tr(args: [reversedBy.id]),
                color: ColorManager.error,
              ),
            const SizedBox(height: AppSize.s16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('finance_close'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
