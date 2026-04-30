import 'package:flutter/material.dart';

class ColorManager {
  // ========================
  // 🎨 Design System (Main)
  // ========================

  // Primary palette
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey900 = Color(0xFF111827);

  // Semantic
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Text
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey500;
  static const Color textDisabled = grey300;

  // Border
  static const Color border = grey300;
  static const Color divider = grey100;

  // ========================
  // ⚠️ Legacy (old usage)
  // ========================

  static const Color primaryBlue = Color(0xff246EFA);
  static const Color darkText = Color(0xff1F1F1F);
  static const Color bodyText = Color(0xff57595D);
  static const Color lightGrey = Color(0xffE3E7ED);
}