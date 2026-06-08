import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/arabesque_bg.dart';
import '../../shared/widgets/staggered_animation.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 48,
        actions: [
          IconButton(
            icon: const Icon(Icons.nightlight_round, color: AppColors.gold),
            tooltip: 'مواقيت الصلاة',
            onPressed: () => context.push(AppConstants.routePrayer),
          ),
        ],
      ),
      body: ArabesqueBackground(
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Header
                  Center(
                    child: Text(
                      '﷽',
                      style: AppTextStyles.displayLarge.copyWith(
                        fontSize: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'بسم الله الرحمن الرحيم',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Main title
                  Text(
                    'الأذكار',
                    style: AppTextStyles.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أذكار وأدعية وتسبيح',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  // Adhkar categories grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.9,
                      children: [
                        StaggeredAnimation(
                          index: 0,
                          child: _buildCategoryCard(
                            context,
                            icon: '🌅',
                            title: 'أذكار الصباح',
                            subtitle: 'من الكتاب والسنة',
                            color: AppColors.teal,
                            onTap: () => context.push(
                              '${AppConstants.routeAdhkar}/morning',
                            ),
                          ),
                        ),
                        StaggeredAnimation(
                          index: 1,
                          child: _buildCategoryCard(
                            context,
                            icon: '🌇',
                            title: 'أذكار المساء',
                            subtitle: 'من الكتاب والسنة',
                            color: AppColors.navyDeep,
                            onTap: () => context.push(
                              '${AppConstants.routeAdhkar}/evening',
                            ),
                          ),
                        ),
                        StaggeredAnimation(
                          index: 2,
                          child: _buildCategoryCard(
                            context,
                            icon: '🕌',
                            title: 'أذكار بعد الصلاة',
                            subtitle: 'أذكار الصلوات',
                            color: AppColors.burgundy,
                            onTap: () => context.push(
                              '${AppConstants.routeAdhkar}/after_prayer',
                            ),
                          ),
                        ),
                        StaggeredAnimation(
                          index: 3,
                          child: _buildCategoryCard(
                            context,
                            icon: '🤲',
                            title: 'الأدعية',
                            subtitle: 'أدعية مأثورة',
                            color: AppColors.goldDark,
                            onTap: () => context.push(
                              AppConstants.routeDuaa,
                            ),
                          ),
                        ),
                        StaggeredAnimation(
                          index: 4,
                          child: _buildCategoryCard(
                            context,
                            icon: '📿',
                            title: 'التسبيح',
                            subtitle: 'عداد إلكتروني',
                            color: AppColors.tealLight,
                            onTap: () => context.push(
                              AppConstants.routeTasbeeh,
                            ),
                          ),
                        ),
                        StaggeredAnimation(
                          index: 5,
                          child: _buildCategoryCard(
                            context,
                            icon: '⚙️',
                            title: 'الإعدادات',
                            subtitle: 'تخصيص التطبيق',
                            color: AppColors.navyMedium,
                            onTap: () => context.push(
                              AppConstants.routeSettings,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: 16,
                  color: isDark ? AppColors.ivory : AppColors.navyDeep,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
