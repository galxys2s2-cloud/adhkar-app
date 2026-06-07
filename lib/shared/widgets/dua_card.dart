import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/adhkar_model.dart';
import '../../features/favorites/providers/favorites_provider.dart';

class DuaCard extends ConsumerStatefulWidget {
  final DuaaModel duaa;

  const DuaCard({
    super.key,
    required this.duaa,
  });

  @override
  ConsumerState<DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends ConsumerState<DuaCard> {
  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = ref.watch(
      favoritesProvider.select((s) => s.isDuaaFavorite(widget.duaa.id)),
    );

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Before/after label + heart
          Row(
            children: [
              if (widget.duaa.beforeAfter != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.duaa.beforeAfter == 'before' ? 'قبل' : 'بعد',
                    style: AppTextStyles.goldLabel.copyWith(
                      fontSize: 12,
                      color: AppColors.tealLight,
                    ),
                  ),
                )
              else
                const Spacer(),
              const Spacer(),
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                ),
                color: isFav ? Colors.red : AppColors.gold,
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggleDuaa(widget.duaa.id);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 22,
              ),
            ],
          ),
          // Text
          Text(
            widget.duaa.arabic,
            style: isDark
                ? AppTextStyles.adhkarTextDark
                : AppTextStyles.adhkarText,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          // Translation and transliteration (collapsible)
          if (widget.duaa.translation != null || widget.duaa.transliteration != null) ...[
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
                  if (widget.duaa.transliteration != null) ...[
                    Text(
                      widget.duaa.transliteration!,
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
                  if (widget.duaa.translation != null) ...[
                    Text(
                      widget.duaa.translation!,
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
          const SizedBox(height: 12),
          // Reference + count
          Row(
            children: [
              if (widget.duaa.count > 1)
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
                    '${widget.duaa.count} مرات',
                    style: AppTextStyles.goldLabel.copyWith(fontSize: 12),
                  ),
                ),
              const Spacer(),
              Text(
                widget.duaa.reference,
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
