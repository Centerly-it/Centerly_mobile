import 'package:flutter/material.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/style_manager.dart';
import '../../../../core/theme/values_manager.dart';

class StudentFilterChip extends StatelessWidget {
  const StudentFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    showCheckmark: false,
    backgroundColor: ColorManager.grey200,
    selectedColor: ColorManager.primary,
    labelStyle: AppTextStyles.bodyMedium.copyWith(
      color: selected ? ColorManager.white : ColorManager.textPrimary,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppPadding.p8,
      vertical: AppPadding.p8,
    ),
    labelPadding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.r16),
      side: BorderSide(
        color: selected ? ColorManager.primary : ColorManager.stroke,
      ),
    ),
  );
}
