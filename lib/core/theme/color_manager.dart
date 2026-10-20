import 'package:flutter/material.dart';

class ColorManager {
  ColorManager._();

  // Primary palette
  static const Color primary = Color(0xFF246EFA);
  static const Color primaryLight = Color(0xFF7FAAFC);
  static const Color primarySoft = Color(0xFFF7FAFF);
  static const Color primaryBright = Color(0xFFE9F1FF);
  static const Color primaryDark = Color(0xFF1558D6);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFF5F5F7);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey900 = Color(0xFF111827);

  static const Color canvas = Color(0xFFFBFCFC);
  static const Color stroke = Color(0xFFE3E6EB);
  static const Color successSurface = Color(0xFFE7F3ED);
  static const Color successBorder = Color(0xFFB4DAC8);
  static const Color successText = Color(0xFF084A2B);

  // Semantic
  static const Color error = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFCEBEB);
  static const Color errorBorder = Color(0xFFF4C0C0);
  static const Color errorText = Color(0xFF7A1D1D);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Calendar status markers (shared by grid and legend).
  static const Color calendarEnded = Color(0xFFAEBBD0);
  static const Color calendarAvailable = Color(0xFF78CCA8);
  static const Color calendarCancelled = Color(0xFFF49B9B);

  // Text
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey500;
  static const Color textDisabled = grey300;

  // Border / Divider
  static const Color border = grey300;
  static const Color divider = grey100;
}
