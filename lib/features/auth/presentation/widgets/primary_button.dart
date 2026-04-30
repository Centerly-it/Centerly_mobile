import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double? radius;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.padding,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: isLandscape ? 48 : 56,
        maxHeight: isLandscape ? 56 : 64,
      ),
      child: SizedBox(
        width: width ?? double.infinity,
        height: MediaQuery.of(context).size.height * 0.08,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.primaryBlue,
            foregroundColor: ColorManager.whiteTextColor,
            disabledBackgroundColor: ColorManager.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 12),
            ),
            padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorManager.whiteTextColor,
                    ),
                  ),
                )
              : FittedBox(
                  child: Text(label, style: StyleManager.head4Meduim(context)),
                ),
        ),
      ),
    );
  }
}
