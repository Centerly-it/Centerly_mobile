import 'package:flutter/material.dart';
import 'color_manager.dart';
import 'font_manager.dart';

// Base style
TextStyle _style(double size, FontWeight weight, Color color) => TextStyle(
      fontFamily: FontFamily.cairo,
      fontSize: size,
      fontWeight: weight,
      color: color,
    );

class AppTextStyles {
  // ========================
  // 🎨 Design System
  // ========================

  // Display
  static TextStyle displayLarge(BuildContext context) =>
      _responsive(context, 32, FontWeightManager.bold, ColorManager.textPrimary);

  static TextStyle displayMedium(BuildContext context) =>
      _responsive(context, 28, FontWeightManager.bold, ColorManager.textPrimary);

  // Headline
  static TextStyle headlineLarge(BuildContext context) =>
      _responsive(context, 24, FontWeightManager.bold, ColorManager.textPrimary);

  static TextStyle headlineMedium(BuildContext context) =>
      _responsive(context, 20, FontWeightManager.semiBold, ColorManager.textPrimary);

  static TextStyle headlineSmall(BuildContext context) =>
      _responsive(context, 18, FontWeightManager.semiBold, ColorManager.textPrimary);

  // Body
  static TextStyle bodyLarge(BuildContext context) =>
      _responsive(context, 16, FontWeightManager.regular, ColorManager.textPrimary);

  static TextStyle bodyMedium(BuildContext context) =>
      _responsive(context, 14, FontWeightManager.regular, ColorManager.textPrimary);

  static TextStyle bodySmall(BuildContext context) =>
      _responsive(context, 12, FontWeightManager.regular, ColorManager.textSecondary);

  // ========================
  // ⚙️ Responsive Logic (بتاعك)
  // ========================

  static TextStyle _responsive(
    BuildContext context,
    double fontSize,
    FontWeight weight,
    Color color,
  ) {
    final size = _getResponsiveFontSize(context, fontSize);
    return _style(size, weight, color);
  }

  static double _getResponsiveFontSize(BuildContext context, double fontSize) {
    double width = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    double scaleFactor = _getScaleFactor(context);
    double responsiveFontSize = fontSize * scaleFactor;

    double lowerLimit;
    double upperLimit;

    if (orientation == Orientation.portrait) {
      if (width < SizeConfig.tablet) {
        lowerLimit = fontSize * 0.9;
        upperLimit = fontSize * 1.2;
      } else if (width < SizeConfig.desktop) {
        lowerLimit = fontSize * 1.1;
        upperLimit = fontSize * 1.4;
      } else {
        lowerLimit = fontSize * 1.2;
        upperLimit = fontSize * 1.6;
      }
    } else {
      if (width < SizeConfig.tablet) {
        lowerLimit = fontSize * 0.8;
        upperLimit = fontSize * 1.1;
      } else if (width < SizeConfig.desktop) {
        lowerLimit = fontSize * 1.2;
        upperLimit = fontSize * 1.5;
      } else {
        lowerLimit = fontSize * 1.3;
        upperLimit = fontSize * 1.7;
      }
    }

    return responsiveFontSize.clamp(lowerLimit, upperLimit);
  }

  static double _getScaleFactor(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;

    if (width < SizeConfig.tablet) {
      return width / 375;
    } else if (width < SizeConfig.desktop) {
      return width / 768;
    } else {
      return width / 1440;
    }
  }
}

class SizeConfig {
  static const mobile = 600;
  static const tablet = 1024;
  static const desktop = 1440;
}