import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_manager.dart';
import '../../../core/theme/style_manager.dart';
import '../../../core/theme/values_manager.dart';
import '../../../core/widgets/app_surface_panel.dart';
import '../domain/finance_plan.dart';
import 'design/finance_design.dart';

class FinanceScenarioPanel extends StatelessWidget {
  const FinanceScenarioPanel({
    required this.plan,
    required this.onChanged,
    super.key,
  });
  final FinancePlan plan;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => AppSurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('finance_scenario_title'.tr(), style: AppTextStyles.headlineSmall),
        Text(
          'finance_scenario_description'.tr(
            args: [financeMoney(plan.remaining)],
          ),
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: AppSize.s16),
        Text(
          'finance_scenario_percent'.tr(args: ['${plan.percent}%']),
          style: AppTextStyles.bodySemiBold,
        ),
        Slider(
          value: plan.percent.toDouble(),
          min: 0,
          max: 100,
          divisions: 4,
          label: '${plan.percent}%',
          onChanged: (v) => onChanged(v.round()),
        ),
        FinanceMoney(
          plan.possibleAddition,
          style: AppTextStyles.headlineLarge.copyWith(
            color: ColorManager.success,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('finance_possible_addition'.tr(), style: AppTextStyles.caption),
      ],
    ),
  );
}
