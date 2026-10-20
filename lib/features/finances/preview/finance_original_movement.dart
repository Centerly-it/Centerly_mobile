import '../presentation/design/finance_detail_line.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/widgets/app_surface_panel.dart';
import '../domain/finance_entry.dart';
import '../presentation/design/finance_design.dart';

class FinanceOriginalMovement extends StatelessWidget {
  const FinanceOriginalMovement({
    required this.original,
    required this.movement,
    super.key,
  });
  final FinanceMovement original, movement;
  @override
  Widget build(BuildContext context) => AppSurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'finance_original_movement'.tr(),
          style: AppTextStyles.bodySemiBold,
        ),
        FinanceDetailLine('finance_receipt'.tr(), original.id),
        FinanceDetailLine(
          'finance_original_actor'.tr(),
          'finance_demo_secretary_${original.actor}'.tr(),
        ),
        FinanceDetailLine(
          'finance_original_amount'.tr(),
          financeMoney(original.amount, exact: true),
        ),
        Text(
          movement.reasonKey?.tr() ?? 'finance_reason_missing'.tr(),
          style: AppTextStyles.bodyMedium,
        ),
      ],
    ),
  );
}
