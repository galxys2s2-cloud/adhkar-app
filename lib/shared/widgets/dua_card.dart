import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/adhkar_model.dart';

class DuaCard extends StatelessWidget {
  final DuaaModel duaa;

  const DuaCard({
    super.key,
    required this.duaa,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Before/after label
          if (duaa.beforeAfter != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                duaa.beforeAfter == 'before' ? 'قبل' : 'بعد',
                style: AppTextStyles.goldLabel.copyWith(
                  fontSize: 12,
                  color: AppColors.tealLight,
                ),
              ),
            ),
          // Text
          Text(
            duaa.arabic,
            style: isDark
                ? AppTextStyles.adhkarTextDark
                : AppTextStyles.adhkarText,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          const SizedBox(height: 12),
          // Reference + count
          Row(
            children: [
              if (duaa.count > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${duaa.count} مرات',
                    style: AppTextStyles.goldLabel.copyWith(fontSize: 12),
                  ),
                ),
              const Spacer(),
              Text(
                duaa.reference,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
