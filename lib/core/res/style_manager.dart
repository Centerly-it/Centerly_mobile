// here we will manage the theme of the app and also we will manage the dark and light theme of the app
import 'package:centrally/core/res/app_constants.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/font_manager.dart';
import 'package:flutter/material.dart';

class StyleManager {
  static TextStyle head3Bold(BuildContext context) {
    return TextStyle(
      fontSize: StyleManager().getResponsiveFontSize(
        context: context,
        fontSize: FontSize.s20,
      ),
      fontWeight: FontWeightManager.bold,
      color: ColorManager.darkText,
      fontFamily: AppConstants.fontFamilyName,
    );
  }

  static TextStyle head4Meduim(BuildContext context) {
    return TextStyle(
      fontSize: StyleManager().getResponsiveFontSize(
        context: context,
        fontSize: FontSize.s18,
      ),
      fontWeight: FontWeightManager.medium,
      color: ColorManager.whiteTextColor,
      fontFamily: AppConstants.fontFamilyName,
    );
  }

  static TextStyle bodyRegular(BuildContext context) {
    return TextStyle(
      fontSize: StyleManager().getResponsiveFontSize(
        context: context,
        fontSize: FontSize.s16,
      ),
      fontWeight: FontWeightManager.regular,
      color: ColorManager.bodyText,
      fontFamily: AppConstants.fontFamilyName,
    );
  }

  static TextStyle bodyMeduim(BuildContext context) {
    return TextStyle(
      fontSize: StyleManager().getResponsiveFontSize(
        context: context,
        fontSize: FontSize.s14,
      ),
      fontWeight: FontWeightManager.medium,
      color: ColorManager.greyLabelColor,
      fontFamily: AppConstants.fontFamilyName,
    );
  }

  static TextStyle bodySemiBold(BuildContext context) {
    return TextStyle(
      fontSize: StyleManager().getResponsiveFontSize(
        context: context,
        fontSize: FontSize.s14,
      ),
      fontWeight: FontWeightManager.semiBold,
      color: ColorManager.primaryBlue,
      fontFamily: AppConstants.fontFamilyName,
    );
  }

  double getResponsiveFontSize({
    required BuildContext context,
    required double fontSize,
  }) {
    double width = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    double scaleFactor = getScaleFactor(context);
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

  double getScaleFactor(BuildContext context) {
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
