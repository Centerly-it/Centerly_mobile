import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:flutter/material.dart';

class ValidationCheck extends StatelessWidget {
  const ValidationCheck({
    super.key,
    required this.validTitle,
    this.isValid = false,
  });
  final String validTitle;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_outlined,
          size: 18,
          color: isValid ? ColorManager.success : ColorManager.grey500,
        ),
        const SizedBox(width: 8),
        Text(
          validTitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: isValid ? ColorManager.success : ColorManager.grey500,
          ),
        ),
      ],
    );
  }
}
