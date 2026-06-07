import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/adhkar_model.dart';
import '../../features/favorites/providers/favorites_provider.dart';

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
  bool _isExpanded = false;

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

  void _toggleExpansion() {
    setState(() => _isExpanded = !_isExpanded);
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          // Translation and transliteration (collapsible)
          if (widget.adhkar.translation != null || widget.adhkar.transliteration != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: _toggleExpansion,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isExpanded ? 'Hide Translation' : 'Show Translation',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.adhkar.transliteration != null) ...[
                    Text(
                      widget.adhkar.transliteration!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (widget.adhkar.translation != null) ...[
                    Text(
                      widget.adhkar.translation!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
          const SizedBox(height: 16),
          // Bottom bar: reference + heart + counter
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
              // Favorite heart
              Consumer(
                builder: (context, ref, child) {
                  final isFav = ref.watch(
                    favoritesProvider.select(
                      (s) => s.isAdhkarFavorite(widget.adhkar.id),
                    ),
                  );
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                    ),
                    color: isFav ? Colors.red : AppColors.gold,
                    onPressed: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleAdhkar(widget.adhkar.id);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 22,
                  );
                },
              ),
              const SizedBox(width: 8),
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
