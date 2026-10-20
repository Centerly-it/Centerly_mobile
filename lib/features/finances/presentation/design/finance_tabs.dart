import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';

class FinanceTabs extends StatelessWidget {
  const FinanceTabs({required this.index, required this.onChanged, super.key});
  final int index;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final large = MediaQuery.textScalerOf(context).scale(16) > 22;
      final items = [
        for (var i = 0; i < 3; i++)
          large
              ? SizedBox(width: 180, child: _tab(i))
              : Expanded(child: _tab(i)),
      ];
      return large
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: items),
            )
          : Row(children: items);
    },
  );
  Widget _tab(int i) => Semantics(
    selected: i == index,
    button: true,
    child: InkWell(
      onTap: () => onChanged(i),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppPadding.p12,
          horizontal: AppPadding.p4,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: i == index ? ColorManager.primary : ColorManager.stroke,
              width: i == index ? 2 : 1,
            ),
          ),
        ),
        child: Text(
          'finance_tab_${['overview', 'dues', 'movements'][i]}'.tr(),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: i == index
                ? ColorManager.primary
                : ColorManager.textSecondary,
            fontWeight: i == index ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    ),
  );
}
