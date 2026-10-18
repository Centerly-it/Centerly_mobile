import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/font_manager.dart';
import 'package:flutter/material.dart';

TextStyle _style(
  double size,
  FontWeight weight,
  Color color, [
  double? height,
]) => TextStyle(
  fontFamily: FontFamily.cairo,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

class AppTextStyles {
  AppTextStyles._();

  // Display
  static final TextStyle displayLarge = _style(
    FontSize.s32,
    FontWeightManager.bold,
    ColorManager.textPrimary,
  );
  static final TextStyle displayMedium = _style(
    FontSize.s28,
    FontWeightManager.bold,
    ColorManager.textPrimary,
  );

  // Headline
  static final TextStyle headlineLarge = _style(
    FontSize.s24,
    FontWeightManager.bold,
    ColorManager.textPrimary,
  );
  static final TextStyle headlineMedium = _style(
    FontSize.s20,
    FontWeightManager.semiBold,
    ColorManager.textPrimary,
  );
  static final TextStyle headlineSmall = _style(
    FontSize.s18,
    FontWeightManager.semiBold,
    ColorManager.textPrimary,
  );

  // Title
  static final TextStyle titleLarge = _style(
    FontSize.s17,
    FontWeightManager.semiBold,
    ColorManager.textPrimary,
  );
  static final TextStyle titleMedium = _style(
    FontSize.s16,
    FontWeightManager.medium,
    ColorManager.textPrimary,
  );
  static final TextStyle titleSmall = _style(
    FontSize.s14,
    FontWeightManager.medium,
    ColorManager.textPrimary,
  );

  // Body
  static final TextStyle bodyLarge = _style(
    FontSize.s16,
    FontWeightManager.regular,
    ColorManager.textPrimary,
    1.7,
  );
  static final TextStyle bodySemiBold = _style(
    FontSize.s14,
    FontWeightManager.semiBold,
    ColorManager.textPrimary,
  );
  static final TextStyle bodyMedium = _style(
    FontSize.s14,
    FontWeightManager.regular,
    ColorManager.textPrimary,
    1.6,
  );
  static final TextStyle bodySmall = _style(
    FontSize.s12,
    FontWeightManager.regular,
    ColorManager.textSecondary,
  );

  // Label
  static final TextStyle labelLarge = _style(
    FontSize.s14,
    FontWeightManager.medium,
    ColorManager.textPrimary,
  );
  static final TextStyle labelSmall = _style(
    FontSize.s12,
    FontWeightManager.medium,
    ColorManager.textSecondary,
  );

  // Caption / hint
  static final TextStyle caption = _style(
    FontSize.s12,
    FontWeightManager.regular,
    ColorManager.textSecondary,
  );
  static final TextStyle hint = _style(
    FontSize.s14,
    FontWeightManager.regular,
    ColorManager.textSecondary,
  );
}
