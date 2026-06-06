import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navyDeep,
        secondary: AppColors.gold,
        surface: AppColors.lightSurface,
        onPrimary: AppColors.ivory,
        onSecondary: AppColors.navyDeep,
        onSurface: AppColors.lightText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        foregroundColor: AppColors.navyDeep,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headingMedium.copyWith(
          color: AppColors.navyDeep,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: AppColors.navyDeep.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.gold,
        thickness: 0.5,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.gold.withValues(alpha: 0.2),
        backgroundColor: AppColors.lightSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.tealLight,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.navyDeep,
        onSecondary: AppColors.ivory,
        onSurface: AppColors.darkText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.gold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headingMedium.copyWith(
          color: AppColors.gold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headingLarge.copyWith(
          color: AppColors.darkText,
        ),
        headlineMedium: AppTextStyles.headingMedium.copyWith(
          color: AppColors.darkText,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.darkText,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.goldDark,
        thickness: 0.5,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.gold.withValues(alpha: 0.2),
        backgroundColor: AppColors.darkSurface,
      ),
    );
  }
}
