import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A single prayer time card showing name, time, and active state.
class PrayerCard extends StatelessWidget {
  final String name;
  final String time;
  final bool isNext;
  final bool isPast;

  const PrayerCard({
    super.key,
    required this.name,
    required this.time,
    this.isNext = false,
    this.isPast = false,
  });

  IconData _getIcon() {
    switch (name) {
      case 'الفجر': return Icons.wb_twilight;
      case 'الشروق': return Icons.wb_sunny;
      case 'الظهر': return Icons.wb_sunny_outlined;
      case 'العصر': return Icons.cloud;
      case 'المغرب': return Icons.nights_stay;
      case 'العشاء': return Icons.nightlight;
      default: return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isNext) {
      borderColor = AppColors.gold;
      bgColor = AppColors.gold.withValues(alpha: 0.1);
      textColor = AppColors.gold;
    } else if (isPast) {
      borderColor = AppColors.gold.withValues(alpha: 0.1);
      bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    } else {
      borderColor = AppColors.gold.withValues(alpha: 0.2);
      bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      textColor = isDark ? AppColors.ivory : AppColors.navyDeep;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isNext ? 2 : 1),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: isNext ? AppColors.gold : textColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 16,
                color: isNext ? AppColors.gold : textColor,
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          // Time
          Text(
            time,
            style: AppTextStyles.counterNumber.copyWith(
              fontSize: 22,
              color: isNext ? AppColors.gold : textColor,
            ),
          ),
          if (isNext) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'التالي',
                style: TextStyle(
                  color: AppColors.navyDeep,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
