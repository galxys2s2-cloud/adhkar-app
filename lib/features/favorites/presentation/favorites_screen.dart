import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/adhkar_model.dart';
import '../../../data/repositories/adhkar_repository.dart';
import '../../../shared/widgets/adhkar_card.dart';
import '../../../shared/widgets/dua_card.dart';
import '../../../shared/widgets/arabesque_bg.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(adhkarRepositoryProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('❤️ المفضلة'),
      ),
      body: ArabesqueBackground(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: FutureBuilder(
            future: Future.wait([
              repository.loadAllAdhkar(),
              repository.loadDuaaList(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Text(
                    'حدث خطأ في تحميل المفضلة',
                    style: AppTextStyles.bodyLarge,
                  ),
                );
              }

              final allAdhkar = (snapshot.data![0] as List<AdhkarModel>);
              final allDuaa = (snapshot.data![1] as List<DuaaModel>);

              final favAdhkar = allAdhkar
                  .where((a) => favorites.adhkarIds.contains(a.id))
                  .toList();
              final favDuaa = allDuaa
                  .where((d) => favorites.duaaIds.contains(d.id))
                  .toList();

              if (favAdhkar.isEmpty && favDuaa.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (favAdhkar.isNotEmpty) ...[
                    _buildSectionHeader(context, '🌅 الأذكار المفضلة'),
                    const SizedBox(height: 12),
                    ...favAdhkar.map((a) => AdhkarCard(adhkar: a)),
                    const SizedBox(height: 24),
                  ],
                  if (favDuaa.isNotEmpty) ...[
                    _buildSectionHeader(context, '🤲 الأدعية المفضلة'),
                    const SizedBox(height: 12),
                    ...favDuaa.map((d) => DuaCard(duaa: d)),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(
        color: AppColors.gold,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: AppColors.gold.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مفضلات',
            style: AppTextStyles.headingMedium.copyWith(
              color: isDark ? AppColors.ivory : AppColors.navyDeep,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على قلب ❤️ بجانب أي ذكر أو دعاء لإضافته هنا',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            label: const Text('العودة للرئيسية'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDeep,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
