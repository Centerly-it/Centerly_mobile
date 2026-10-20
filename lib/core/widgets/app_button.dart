import 'package:flutter/material.dart';
import '../theme/style_manager.dart';
import '../theme/values_manager.dart';
import '../theme/color_manager.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool outlined;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Text(
      text,
      style: AppTextStyles.titleMedium.copyWith(
        color: outlined ? ColorManager.primary : ColorManager.white,
      ),
    );

    return SizedBox(
      height: AppSize.s54,
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: onPressed, child: child)
          : FilledButton(onPressed: onPressed, child: child),
    );
  }
}
