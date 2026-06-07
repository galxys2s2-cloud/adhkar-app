import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../../core/constants/app_constants.dart';

/// Service for scheduling and showing local notifications
/// using flutter_local_notifications ^17.x
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notifications.initialize(initSettings);

    // Create the Android notification channel
    const androidChannel = AndroidNotificationChannel(
      AppConstants.notifChannelId,
      AppConstants.notifChannelName,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  static Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  /// Show an immediate notification
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      AppConstants.notifChannelId,
      AppConstants.notifChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  /// Schedule daily morning adhkar notification at 6:00 AM
  static Future<void> scheduleMorningAdhkar() async {
    await _ensureInitialized();
    await _scheduleDaily(
      id: AppConstants.notifMorningId.hashCode,
      title: 'أذكار الصباح 🌅',
      body: '﴿ يَا أَيُّهَا الَّذِينَ آمَنُوا اذْكُرُوا اللَّهَ ذِكْرًا كَثِيرًا ﴾',
      hour: 6,
      minute: 0,
    );
  }

  /// Schedule daily evening adhkar notification at 5:00 PM
  static Future<void> scheduleEveningAdhkar() async {
    await _ensureInitialized();
    await _scheduleDaily(
      id: AppConstants.notifEveningId.hashCode,
      title: 'أذكار المساء 🌇',
      body: '﴿ فَاذْكُرُونِي أَذْكُرْكُمْ ﴾',
      hour: 17,
      minute: 0,
    );
  }

  /// Schedule random tasbeeh reminders throughout the day
  static Future<void> scheduleRandomTasbeeh() async {
    await _ensureInitialized();

    final reminders = [
      _TasbeehReminder(10, 0, 'سبّح الله في الصباح 🌅'),
      _TasbeehReminder(14, 0, 'اذكر الله — سبحان الله وبحمده ☀️'),
      _TasbeehReminder(20, 0, 'أستغفر الله العظيم 🌙'),
    ];

    for (int i = 0; i < reminders.length; i++) {
      final r = reminders[i];
      await _scheduleDaily(
        id: '${AppConstants.notifRandomId}_$i'.hashCode,
        title: 'تذكير بالتسبيح 📿',
        body: r.body,
        hour: r.hour,
        minute: r.minute,
      );
    }
  }

  /// Cancel morning adhkar notification
  static Future<void> cancelMorningAdhkar() async {
    await _notifications.cancel(AppConstants.notifMorningId.hashCode);
  }

  /// Cancel evening adhkar notification
  static Future<void> cancelEveningAdhkar() async {
    await _notifications.cancel(AppConstants.notifEveningId.hashCode);
  }

  /// Cancel random tasbeeh reminders
  static Future<void> cancelRandomTasbeeh() async {
    for (int i = 0; i < 3; i++) {
      await _notifications.cancel('${AppConstants.notifRandomId}_$i'.hashCode);
    }
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      AppConstants.notifChannelId,
      AppConstants.notifChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

class _TasbeehReminder {
  final int hour;
  final int minute;
  final String body;

  _TasbeehReminder(this.hour, this.minute, this.body);
}

/// Daily adhkar widget for the home screen
class DailyAdhkarWidget extends StatelessWidget {
  const DailyAdhkarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isMorning = hour < 12;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMorning
              ? [const Color(0xFF00695C), const Color(0xFF4DB6AC)]
              : [const Color(0xFF1A237E), const Color(0xFF3949AB)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            isMorning ? '🌅' : '🌇',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMorning ? 'أذكار الصباح' : 'أذكار المساء',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMorning
                      ? '﴿ يَا أَيُّهَا الَّذِينَ آمَنُوا اذْكُرُوا اللَّهَ ذِكْرًا كَثِيرًا ﴾'
                      : '﴿ فَاذْكُرُونِي أَذْكُرْكُمْ ﴾',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withValues(alpha: 0.7),
            size: 16,
          ),
        ],
      ),
    );
  }
}
