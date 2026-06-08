import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../core/constants/app_constants.dart';
import '../data/prayer_times_model.dart';

/// Manages prayer time notifications.
class PrayerNotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  PrayerNotificationService(this._plugin);

  /// Schedule notifications for today's remaining prayers.
  Future<void> schedulePrayerNotifications(PrayerTimesModel timings) async {
    await cancelAllPrayerNotifications();

    final now = DateTime.now();
    final prayers = timings.allTimes;

    int id = 1000;
    for (final entry in prayers.entries) {
      if (entry.key == 'الشروق') continue;

      final parts = entry.value.split(':');
      final prayerTime = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );

      if (prayerTime.isAfter(now)) {
        await _scheduleSingle(
          id: id++,
          name: entry.key,
          prayerTime: prayerTime,
        );
      }
    }
  }

  Future<void> _scheduleSingle({
    required int id,
    required String name,
    required DateTime prayerTime,
  }) async {
    final scheduledDate = tz.TZDateTime.from(prayerTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات أوقات الصلاة',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'notification_icon',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      '🕌 حان وقت صلاة $name',
      '﷽ — اللهم تقبل',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// Cancel all prayer notifications (IDs 1000+).
  Future<void> cancelAllPrayerNotifications() async {
    for (int id = 1000; id < 1010; id++) {
      await _plugin.cancel(id);
    }
  }
}
