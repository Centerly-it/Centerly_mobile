import 'package:flutter/material.dart';
import 'color_manager.dart';
import 'font_manager.dart';
import 'style_manager.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: FontFamily.cairo,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: ColorManager.primary,
          onPrimary: ColorManager.white,
          primaryContainer: ColorManager.primaryLight,
          onPrimaryContainer: ColorManager.white,
          secondary: ColorManager.primaryLight,
          onSecondary: ColorManager.white,
          secondaryContainer: ColorManager.grey100,
          onSecondaryContainer: ColorManager.textPrimary,
          error: ColorManager.error,
          onError: ColorManager.white,
          errorContainer: ColorManager.errorLight,
          onErrorContainer: ColorManager.error,
          surface: ColorManager.surface,
          onSurface: ColorManager.textPrimary,
          outline: ColorManager.border,
          outlineVariant: ColorManager.divider,
        ),
        scaffoldBackgroundColor: ColorManager.background,
        appBarTheme: AppBarTheme(
          backgroundColor: ColorManager.surface,
          foregroundColor: ColorManager.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.titleLarge,
          iconTheme: const IconThemeData(color: ColorManager.textPrimary),
          surfaceTintColor: Colors.transparent,
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          titleSmall: AppTextStyles.titleSmall,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelSmall: AppTextStyles.labelSmall,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: ColorManager.primary,
            foregroundColor: ColorManager.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: ColorManager.primary,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: ColorManager.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ColorManager.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ColorManager.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ColorManager.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ColorManager.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ColorManager.error),
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: ColorManager.textSecondary),
          labelStyle: AppTextStyles.bodyMedium,
        ),
        cardTheme: CardThemeData(
          color: ColorManager.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: ColorManager.divider),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: ColorManager.divider,
          thickness: 1,
          space: 0,
        ),
      );
}
