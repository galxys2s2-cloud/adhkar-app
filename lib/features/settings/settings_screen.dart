import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/utils/notification_service.dart';
import '../../shared/widgets/arabesque_bg.dart';
import '../../shared/widgets/staggered_animation.dart';
import '../prayer/providers/time_format_provider.dart';
import '../prayer/providers/prayer_notification_provider.dart';
import '../prayer/providers/prayer_provider.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

// Notification toggle providers
final morningAdhkarEnabledProvider = StateProvider<bool>((ref) => false);
final eveningAdhkarEnabledProvider = StateProvider<bool>((ref) => false);
final randomTasbeehEnabledProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final morningEnabled = ref.watch(morningAdhkarEnabledProvider);
    final eveningEnabled = ref.watch(eveningAdhkarEnabledProvider);
    final tasbeehEnabled = ref.watch(randomTasbeehEnabledProvider);
    final is12h = ref.watch(is12hFormatProvider);
    final prayerNotifsEnabled = ref.watch(prayerNotificationsEnabledProvider);

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
              StaggeredAnimation(
                index: 0,
                child: _buildSectionHeader('المظهر'),
              ),
              const SizedBox(height: 12),
              StaggeredAnimation(
                index: 1,
                child: _buildSettingCard(
                  context,
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  title: 'الوضع الليلي',
                  subtitle: 'تغيير مظهر التطبيق',
                  trailing: Switch.adaptive(
                    value: isDark,
                    activeTrackColor: AppColors.gold,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).state =
                          value ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Notifications section
              StaggeredAnimation(
                index: 2,
                child: _buildSectionHeader('الإشعارات'),
              ),
              const SizedBox(height: 12),
              StaggeredAnimation(
                index: 3,
                child: _buildSettingCard(
                  context,
                  icon: Icons.notifications_active,
                  title: 'أذكار الصباح',
                  subtitle: 'تنبيه يومي بعد الفجر (٦:٠٠ صباحاً)',
                  trailing: Switch.adaptive(
                    value: morningEnabled,
                    activeTrackColor: AppColors.gold,
                    onChanged: (value) async {
                      ref.read(morningAdhkarEnabledProvider.notifier).state = value;
                      if (value) {
                        await NotificationService.scheduleMorningAdhkar();
                      } else {
                        await NotificationService.cancelMorningAdhkar();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              StaggeredAnimation(
                index: 4,
                child: _buildSettingCard(
                  context,
                  icon: Icons.notifications_active,
                  title: 'أذكار المساء',
                  subtitle: 'تنبيه يومي قبل المغرب (٥:٠٠ مساء)',
                  trailing: Switch.adaptive(
                    value: eveningEnabled,
                    activeTrackColor: AppColors.gold,
                    onChanged: (value) async {
                      ref.read(eveningAdhkarEnabledProvider.notifier).state = value;
                      if (value) {
                        await NotificationService.scheduleEveningAdhkar();
                      } else {
                        await NotificationService.cancelEveningAdhkar();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              StaggeredAnimation(
                index: 5,
                child: _buildSettingCard(
                  context,
                  icon: Icons.notifications,
                  title: 'تذكير عشوائي (سبحلي)',
                  subtitle: 'تذكير للتسبيح خلال اليوم',
                  trailing: Switch.adaptive(
                    value: tasbeehEnabled,
                    activeTrackColor: AppColors.gold,
                    onChanged: (value) async {
                      ref.read(randomTasbeehEnabledProvider.notifier).state = value;
                      if (value) {
                        await NotificationService.scheduleRandomTasbeeh();
                      } else {
                        await NotificationService.cancelRandomTasbeeh();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Prayer Times section
              StaggeredAnimation(
                index: 6,
                child: _buildSectionHeader('مواقيت الصلاة'),
              ),
              const SizedBox(height: 12),
              StaggeredAnimation(
                index: 7,
                child: _buildSettingCard(
                  context,
                  icon: Icons.access_time,
                  title: 'صيغة ١٢ ساعة',
                  subtitle: is12h ? 'مثال: ٥:٢٣ ص - ٩:٣٠ م' : 'مثال: 05:23 - 21:30',
                  trailing: Switch.adaptive(
                    value: is12h,
                    activeTrackColor: AppColors.gold,
                    onChanged: (value) {
                      ref.read(is12hFormatProvider.notifier).set(value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Prayer Notifications toggle
              StaggeredAnimation(
                index: 8,
                child: _buildSettingCard(
                  context,
                  icon: Icons.mosque,
                  title: 'إشعارات الصلاة',
                  subtitle: 'تنبيه عند دخول وقت كل صلاة',
                  trailing: Switch.adaptive(
                    value: prayerNotifsEnabled,
                    activeTrackColor: AppColors.gold,
                    onChanged: (value) async {
                      await ref.read(prayerNotificationsEnabledProvider.notifier).set(value);
                      if (value) {
                        final timings = ref.read(prayerTimingsProvider).valueOrNull;
                        if (timings != null) {
                          final service = ref.read(prayerNotificationServiceProvider);
                          await service.schedulePrayerNotifications(timings);
                        }
                      } else {
                        final service = ref.read(prayerNotificationServiceProvider);
                        await service.cancelAllPrayerNotifications();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // About section
              StaggeredAnimation(
                index: 9,
                child: _buildSectionHeader('حول التطبيق'),
              ),
              const SizedBox(height: 12),
              StaggeredAnimation(
                index: 10,
                child: _buildSettingCard(
                  context,
                  icon: Icons.info_outline,
                  title: AppConstants.appName,
                  subtitle: 'الإصدار ${AppConstants.appVersion}',
                  trailing: const Text(
                    '🕌',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer
              StaggeredAnimation(
                index: 11,
                child: Column(
                  children: [
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
                  ],
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
