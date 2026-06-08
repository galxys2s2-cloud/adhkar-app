import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../prayer/data/prayer_times_model.dart';

/// Manages prayer time notifications.
class PrayerNotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  PrayerNotificationService(this._plugin);

  /// Schedule notifications for today's remaining prayers.
  Future<void> schedulePrayerNotifications(PrayerTimesModel timings) async {
    // Cancel all pending prayer notifications
    await cancelAllPrayerNotifications();

    final now = DateTime.now();
    final prayers = timings.allTimes;

    int id = 1000; // Start prayer IDs at 1000 to avoid conflicts
    for (final entry in prayers.entries) {
      // Skip sunrise — it's not a prayer
      if (entry.key == 'الشروق') continue;

      final parts = entry.value.split(':');
      final prayerTime = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );

      // Only schedule future prayers
      if (prayerTime.isAfter(now)) {
        await _scheduleSinglePrayer(
          id: id++,
          name: entry.key,
          prayerTime: prayerTime,
        );
      }
    }
  }

  Future<void> _scheduleSinglePrayer({
    required int id,
    required String name,
    required DateTime prayerTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات أوقات الصلاة',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'notification_icon',
      sound: 'azan_sound',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.schedule(
      id,
      '🕌 حان وقت صلاة $name',
      '﷽ — حان وقت الصلاة. اللهم تقبل',
      prayerTime,
      details,
    );
  }

  /// Cancel all prayer notifications (IDs 1000+).
  Future<void> cancelAllPrayerNotifications() async {
    for (int id = 1000; id < 1010; id++) {
      await _plugin.cancel(id);
    }
  }
}
