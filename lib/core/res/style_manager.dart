import 'package:flutter/material.dart';
import 'color_manager.dart';
import 'font_manager.dart';

TextStyle _style(double size, FontWeight weight, Color color) => TextStyle(
      fontFamily: FontFamily.cairo,
      fontSize: size,
      fontWeight: weight,
      color: color,
    );

class AppTextStyles {
  // Display
  static TextStyle displayLarge = _style(32, FontWeightManager.bold, ColorManager.textPrimary);
  static TextStyle displayMedium = _style(28, FontWeightManager.bold, ColorManager.textPrimary);

  // Headline
  static TextStyle headlineLarge = _style(24, FontWeightManager.bold, ColorManager.textPrimary);
  static TextStyle headlineMedium = _style(20, FontWeightManager.semiBold, ColorManager.textPrimary);
  static TextStyle headlineSmall = _style(18, FontWeightManager.semiBold, ColorManager.textPrimary);

  // Title
  static TextStyle titleLarge = _style(17, FontWeightManager.semiBold, ColorManager.textPrimary);
  static TextStyle titleMedium = _style(16, FontWeightManager.medium, ColorManager.textPrimary);
  static TextStyle titleSmall = _style(14, FontWeightManager.medium, ColorManager.textPrimary);

  // Body
  static TextStyle bodyLarge = _style(16, FontWeightManager.regular, ColorManager.textPrimary);
  static TextStyle bodyMedium = _style(14, FontWeightManager.regular, ColorManager.textPrimary);
  static TextStyle bodySmall = _style(12, FontWeightManager.regular, ColorManager.textSecondary);

  // Label
  static TextStyle labelLarge = _style(14, FontWeightManager.medium, ColorManager.textPrimary);
  static TextStyle labelSmall = _style(12, FontWeightManager.medium, ColorManager.textSecondary);
}
