import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/values_manager.dart';

class FinanceCardRings extends StatelessWidget {
  const FinanceCardRings({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: AppSize.s200,
    height: AppSize.s200,
    padding: const EdgeInsets.all(AppPadding.p24),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: ColorManager.white.withAlpha(42),
        width: AppSize.s1,
      ),
    ),
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorManager.white.withAlpha(18),
        border: Border.all(
          color: ColorManager.white.withAlpha(42),
          width: AppSize.s1,
        ),
      ),
    ),
  );
}
