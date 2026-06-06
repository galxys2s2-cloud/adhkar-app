import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Base Amiri text style with correct font family from assets.
  static const TextStyle _amiriBase = TextStyle(
    fontFamily: 'Amiri',
  );

  // Arabic display fonts
  static TextStyle get amiriRegular => _amiriBase.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get amiriBold => _amiriBase.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.6,
      );

  // Heading styles
  static TextStyle get displayLarge => _amiriBase.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        height: 1.3,
      );

  static TextStyle get displayMedium => _amiriBase.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        height: 1.3,
      );

  static TextStyle get headingLarge => _amiriBase.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.navyDeep,
        height: 1.4,
      );

  static TextStyle get headingMedium => _amiriBase.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.navyDeep,
        height: 1.4,
      );

  // Adhkar text style (large Arabic)
  static TextStyle get adhkarText => _amiriBase.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.navyDeep,
        height: 2.0,
        letterSpacing: 0.5,
      );

  static TextStyle get adhkarTextDark => _amiriBase.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.ivory,
        height: 2.0,
        letterSpacing: 0.5,
      );

  // Body text (Arabic-supporting system font or Amiri)
  static TextStyle get bodyLarge => _amiriBase.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.lightText,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _amiriBase.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextSecondary,
        height: 1.5,
      );

  // Gold decorative text
  static TextStyle get goldLabel => _amiriBase.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.gold,
      );

  // Tasbeeh counter style
  static TextStyle get counterNumber => _amiriBase.copyWith(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
      );
}
