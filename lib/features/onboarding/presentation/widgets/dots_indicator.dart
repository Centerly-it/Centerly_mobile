import 'package:flutter/material.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';

class DotsIndicator extends StatelessWidget {
  const DotsIndicator({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(count, (i) {
          return DotItem(isActive: i == current);
        }),
      ),
    );
  }
}

class DotItem extends StatelessWidget {
  final bool isActive;

  const DotItem({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: AppSize.s5),
      width: isActive ? AppSize.s24 : AppSize.s8,
      height: AppSize.s8,
      decoration: BoxDecoration(
        color: isActive ? ColorManager.primary : ColorManager.grey300,
        borderRadius: BorderRadius.circular(AppSize.s8),
      ),
    );
  }
}
