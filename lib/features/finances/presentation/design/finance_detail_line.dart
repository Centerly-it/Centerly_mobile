import 'package:flutter/material.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';

class FinanceDetailLine extends StatelessWidget {
  const FinanceDetailLine(this.label, this.value, {super.key});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: AppSize.s16,
      runSpacing: AppSize.s4,
      children: [
        Text(label, style: AppTextStyles.caption),
        SelectableText(value, style: AppTextStyles.bodyMedium),
      ],
    ),
  );
}
