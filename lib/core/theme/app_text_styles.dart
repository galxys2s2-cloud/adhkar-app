import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Arabic display fonts
  static TextStyle get amiriRegular => GoogleFonts.amiri(
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get amiriBold => GoogleFonts.amiri(
        fontWeight: FontWeight.w700,
        height: 1.6,
      );

  // Heading styles
  static TextStyle get displayLarge => GoogleFonts.amiri(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        height: 1.3,
      );

  static TextStyle get displayMedium => GoogleFonts.amiri(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        height: 1.3,
      );

  static TextStyle get headingLarge => GoogleFonts.amiri(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.navyDeep,
        height: 1.4,
      );

  static TextStyle get headingMedium => GoogleFonts.amiri(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.navyDeep,
        height: 1.4,
      );

  // Adhkar text style (large Arabic)
  static TextStyle get adhkarText => GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.navyDeep,
        height: 2.0,
        letterSpacing: 0.5,
      );

  static TextStyle get adhkarTextDark => GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.ivory,
        height: 2.0,
        letterSpacing: 0.5,
      );

  // Body text
  static TextStyle get bodyLarge => GoogleFonts.notoNaskhArabic(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.lightText,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.notoNaskhArabic(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextSecondary,
        height: 1.5,
      );

  // Gold decorative text
  static TextStyle get goldLabel => GoogleFonts.amiri(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.gold,
      );

  // Tasbeeh counter style
  static TextStyle get counterNumber => GoogleFonts.amiri(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
      );
}
