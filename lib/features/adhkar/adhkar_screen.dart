import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/adhkar_repository.dart';
import '../../data/models/adhkar_model.dart';
import '../../shared/widgets/arabesque_bg.dart';

class AdhkarScreen extends ConsumerWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.read(adhkarRepositoryProvider).getAdhkarCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ArabesqueBackground(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر القسم',
                  style: AppTextStyles.headingLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'أذكار من الكتاب والسنة',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return _buildCategoryItem(context, cat);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel cat) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push(
        '${AppConstants.routeAdhkar}/${cat.key}',
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Text(cat.icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 18,
                      color: isDark ? AppColors.ivory : AppColors.navyDeep,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: AppColors.gold,
            ),
          ],
        ),
      ),
    );
  }
}
