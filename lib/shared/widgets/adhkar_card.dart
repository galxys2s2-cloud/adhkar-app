import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/adhkar_model.dart';

class AdhkarCard extends StatefulWidget {
  final AdhkarModel adhkar;

  const AdhkarCard({
    super.key,
    required this.adhkar,
  });

  @override
  State<AdhkarCard> createState() => _AdhkarCardState();
}

class _AdhkarCardState extends State<AdhkarCard> {
  int _remainingCount = 0;

  @override
  void initState() {
    super.initState();
    _remainingCount = widget.adhkar.count;
  }

  void _increment() {
    if (_remainingCount > 0) {
      setState(() => _remainingCount--);
    }
  }

  void _reset() {
    setState(() => _remainingCount = widget.adhkar.count);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = _remainingCount <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? AppColors.tealLight.withValues(alpha: 0.5)
              : AppColors.gold.withValues(alpha: 0.15),
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bismillah
          if (widget.adhkar.hasBismillah)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  style: AppTextStyles.adhkarText.copyWith(
                    fontSize: 18,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
          // Adhkar text (softWrap = true to handle long Arabic text like Ayat al-Kursi)
          Text(
            widget.adhkar.arabic,
            style: isDark
                ? AppTextStyles.adhkarTextDark
                : AppTextStyles.adhkarText,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          const SizedBox(height: 16),
          // Bottom bar: reference + counter
          Row(
            children: [
              // Reference
              Expanded(
                child: Text(
                  widget.adhkar.reference,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              // Counter
              GestureDetector(
                onTap: _increment,
                onLongPress: _reset,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.tealLight.withValues(alpha: 0.2)
                        : AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.tealLight.withValues(alpha: 0.3)
                          : AppColors.gold.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_remainingCount/${widget.adhkar.count}',
                        style: AppTextStyles.goldLabel.copyWith(
                          fontSize: 13,
                          color: isCompleted
                              ? AppColors.tealLight
                              : AppColors.gold,
                        ),
                      ),
                      if (_remainingCount > 0) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: AppColors.gold,
                        ),
                      ] else ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.tealLight,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
