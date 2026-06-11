import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/prayer_notification_service.dart';
import '../../../core/services/notification_service.dart';

/// Hive-backed toggle: persist prayer notification preference across restarts.
final prayerNotificationsEnabledProvider =
    StateNotifierProvider<PrayerNotifToggleNotifier, bool>((ref) {
  return PrayerNotifToggleNotifier();
});

class PrayerNotifToggleNotifier extends StateNotifier<bool> {
  PrayerNotifToggleNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox('prayer');
    state = box.get('notifications_enabled', defaultValue: true) as bool;
  }

  Future<void> set(bool value) async {
    state = value;
    final box = await Hive.openBox('prayer');
    await box.put('notifications_enabled', value);
  }
}

/// Provides PrayerNotificationService wired to the shared plugin instance.
final prayerNotificationServiceProvider =
    Provider<PrayerNotificationService>((ref) {
  return PrayerNotificationService(NotificationService.plugin);
});
