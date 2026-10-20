import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';
import '../../domain/finance_entry.dart';
import 'finance_design.dart';

class FinanceMovementTags extends StatelessWidget {
  const FinanceMovementTags({
    required this.movement,
    required this.color,
    super.key,
  });
  final FinanceMovement movement;
  final Color color;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSize.s8,
    runSpacing: AppSize.s4,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      FinancePill(
        (movement.reversed ? 'finance_correction' : 'finance_collection').tr(),
        color: color,
      ),
      Text(
        'completion_method_${movement.method}'.tr(),
        style: AppTextStyles.caption,
      ),
      Text(
        'finance_recorded_by'.tr(
          args: ['finance_demo_secretary_${movement.actor}'.tr()],
        ),
        style: AppTextStyles.caption,
      ),
    ],
  );
}
