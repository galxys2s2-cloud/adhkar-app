import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/arabesque_bg.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: ArabesqueBackground(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Theme section
              _buildSectionHeader('المظهر'),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                title: 'الوضع الليلي',
                subtitle: 'تغيير مظهر التطبيق',
                trailing: Switch.adaptive(
                  value: isDark,
                  activeColor: AppColors.gold,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).state =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Notifications section
              _buildSectionHeader('الإشعارات'),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                icon: Icons.notifications_active,
                title: 'أذكار الصباح',
                subtitle: 'تنبيه يومي بعد الفجر (٦:٠٠ صباحاً)',
                trailing: Switch.adaptive(
                  value: true,
                  activeColor: AppColors.gold,
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.notifications_active,
                title: 'أذكار المساء',
                subtitle: 'تنبيه يومي قبل المغرب (٥:٠٠ مساء)',
                trailing: Switch.adaptive(
                  value: true,
                  activeColor: AppColors.gold,
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.notifications,
                title: 'تذكير عشوائي (سبحلي)',
                subtitle: 'تذكير للتسبيح خلال اليوم',
                trailing: Switch.adaptive(
                  value: true,
                  activeColor: AppColors.gold,
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(height: 24),

              // About section
              _buildSectionHeader('حول التطبيق'),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                icon: Icons.info_outline,
                title: AppConstants.appName,
                subtitle: 'الإصدار ${AppConstants.appVersion}',
                trailing: Text(
                  '🕌',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 24),

              // Footer
              Center(
                child: Text(
                  '﷽',
                  style: AppTextStyles.displayMedium.copyWith(
                    fontSize: 24,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'بسم الله الرحمن الرحيم',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(
        color: AppColors.gold,
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 16,
                    color: isDark ? AppColors.ivory : AppColors.navyDeep,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

// ThemeMode is handled globally via themeModeProvider in main.dart
