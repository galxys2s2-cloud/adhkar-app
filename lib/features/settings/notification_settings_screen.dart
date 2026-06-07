import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/arabesque_bg.dart';
import 'notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final service = NotificationService();
    await service.init();
    final canNotify = await service.canScheduleExactNotifications;
    if (!canNotify && mounted) {
      final granted = await service.requestPermissions();
      if (!granted && mounted) {
        _showPermissionSnack();
      }
    }
    // Also request exact alarm permission for scheduling
    await service.requestExactAlarmPermission();
  }

  void _showPermissionSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('يجب السماح بإذن الإشعارات من إعدادات الجهاز للتمكّن من التشغيل'),
        backgroundColor: AppColors.burgundy,
      ),
    );
  }

  Future<void> _pickTime({
    required int initialHour,
    required int initialMinute,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              hourMinuteTextColor: AppColors.gold,
              dialHandColor: AppColors.gold,
              dialBackgroundColor: AppColors.gold.withValues(alpha: 0.1),
              entryModeIconColor: AppColors.gold,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الإشعارات'),
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
              // Explanation card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.teal, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'اختر أذكار يومية والوقت المناسب للتذكير. سيتم استلام ذكر عشوائي من أذكار الصباح والمساء يومياً.',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Morning section
              _buildSectionHeader('☼️ أذكار الصباح'),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                icon: Icons.notifications_active,
                title: 'تشغيل إشعار الصباح',
                subtitle: settings.morningEnabled
                    ? 'سيتم التذكير يومياً على الساعة ${_formatTime(settings.morningHour, settings.morningMinute)}'
                    : 'الإشعار موقف',
                trailing: Switch.adaptive(
                  value: settings.morningEnabled,
                  activeTrackColor: AppColors.gold,
                  onChanged: (value) => notifier.toggleMorning(value),
                ),
                onTap: () => notifier.toggleMorning(!settings.morningEnabled),
              ),
              if (settings.morningEnabled) ...[
                const SizedBox(height: 8),
                _buildSettingCard(
                  context,
                  icon: Icons.access_time,
                  title: 'وقت التذكير',
                  subtitle: 'اختر وقت إشعار الصباح',
                  trailing: Text(
                    _formatTime(settings.morningHour, settings.morningMinute),
                    style: AppTextStyles.goldLabel.copyWith(fontSize: 16),
                  ),
                  onTap: () => _pickTime(
                    initialHour: settings.morningHour,
                    initialMinute: settings.morningMinute,
                    onPicked: (time) => notifier.setMorningTime(
                      time.hour,
                      time.minute,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Evening section
              _buildSectionHeader('🌇 أذكار المساء'),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                icon: Icons.notifications_active,
                title: 'تشغيل إشعار المساء',
                subtitle: settings.eveningEnabled
                    ? 'سيتم التذكير يومياً على الساعة ${_formatTime(settings.eveningHour, settings.eveningMinute)}'
                    : 'الإشعار موقف',
                trailing: Switch.adaptive(
                  value: settings.eveningEnabled,
                  activeTrackColor: AppColors.gold,
                  onChanged: (value) => notifier.toggleEvening(value),
                ),
                onTap: () => notifier.toggleEvening(!settings.eveningEnabled),
              ),
              if (settings.eveningEnabled) ...[
                const SizedBox(height: 8),
                _buildSettingCard(
                  context,
                  icon: Icons.access_time,
                  title: 'وقت التذكير',
                  subtitle: 'اختر وقت إشعار المساء',
                  trailing: Text(
                    _formatTime(settings.eveningHour, settings.eveningMinute),
                    style: AppTextStyles.goldLabel.copyWith(fontSize: 16),
                  ),
                  onTap: () => _pickTime(
                    initialHour: settings.eveningHour,
                    initialMinute: settings.eveningMinute,
                    onPicked: (time) => notifier.setEveningTime(
                      time.hour,
                      time.minute,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Cancel all button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await NotificationService().cancelAll();
                    await notifier.save(
                      settings.copyWith(
                        morningEnabled: false,
                        eveningEnabled: false,
                      ),
                    );
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('✅ تم إلغاء جميع الإشعارات'),
                        backgroundColor: AppColors.teal,
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_off, size: 18),
                  label: const Text('إلغاء جميع الإشعارات'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.burgundy,
                    side: const BorderSide(color: AppColors.burgundy),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
        fontSize: 18,
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
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
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
