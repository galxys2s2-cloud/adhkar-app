import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/adhkar_repository.dart';
import '../../shared/widgets/arabesque_bg.dart';

class AdhkarDetailScreen extends ConsumerWidget {
  final String category;

  const AdhkarDetailScreen({
    super.key,
    required this.category,
  });

  String get _title {
    switch (category) {
      case 'morning':
        return 'أذكار الصباح';
      case 'evening':
        return 'أذكار المساء';
      case 'after_prayer':
        return 'أذكار بعد الصلاة';
      default:
        return 'الأذكار';
    }
  }

  String get _icon {
    switch (category) {
      case 'morning':
        return '🌅';
      case 'evening':
        return '🌇';
      case 'after_prayer':
        return '🕌';
      default:
        return '📖';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(adhkarRepositoryProvider);
    final adhkarList = repository.loadByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text('$_icon $_title'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ArabesqueBackground(
        child: FutureBuilder(
          future: adhkarList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'حدث خطأ في تحميل الأذكار',
                  style: AppTextStyles.bodyLarge,
                ),
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Text(
                  'سيتم إضافة الأذكار قريباً...',
                  style: AppTextStyles.bodyLarge,
                ),
              );
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final adhkar = items[index];
                  return _buildAdhkarCard(context, adhkar);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdhkarCard(BuildContext context, adhkar) {
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
          if (adhkar.hasBismillah)
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
          Text(
            adhkar.arabic,
            style: isDark
                ? AppTextStyles.adhkarTextDark
                : AppTextStyles.adhkarText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (adhkar.count > 1)
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
                    '${adhkar.count} مرات',
                    style: AppTextStyles.goldLabel.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                adhkar.reference,
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
