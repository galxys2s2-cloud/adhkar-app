import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/arabesque_bg.dart';
import 'notification_settings_provider.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifSettings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
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
                subtitle: notifSettings.morningEnabled
                    ? 'مفعّل — ${_formatTime(notifSettings.morningHour, notifSettings.morningMinute)}'
                    : 'معطّل',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch.adaptive(
                      value: notifSettings.morningEnabled,
                      activeColor: AppColors.gold,
                      onChanged: (value) {
                        ref
                            .read(notificationSettingsProvider.notifier)
                            .toggleMorning(value);
                      },
                    ),
                    const Icon(Icons.chevron_left, color: AppColors.gold),
                  ],
                ),
                onTap: () => context.push(AppConstants.routeNotificationSettings),
              ),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.notifications_active,
                title: 'أذكار المساء',
                subtitle: notifSettings.eveningEnabled
                    ? 'مفعّل — ${_formatTime(notifSettings.eveningHour, notifSettings.eveningMinute)}'
                    : 'معطّل',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch.adaptive(
                      value: notifSettings.eveningEnabled,
                      activeColor: AppColors.gold,
                      onChanged: (value) {
                        ref
                            .read(notificationSettingsProvider.notifier)
                            .toggleEvening(value);
                      },
                    ),
                    const Icon(Icons.chevron_left, color: AppColors.gold),
                  ],
                ),
                onTap: () => context.push(AppConstants.routeNotificationSettings),
              ),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.settings,
                title: 'إعدادات الإشعارات',
                subtitle: 'تخصيص الوقت والتنبيهات',
                trailing: const Icon(Icons.chevron_left, color: AppColors.gold),
                onTap: () => context.push(AppConstants.routeNotificationSettings),
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
                trailing: const Text(
                  '🕌',
                  style: TextStyle(fontSize: 24),
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
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ThemeMode is handled globally via themeModeProvider in main.dart
