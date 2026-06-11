import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:hive/hive.dart';
import '../../data/models/adhkar_model.dart';
import '../../data/repositories/adhkar_repository.dart';
import '../constants/app_constants.dart';

/// Pending route from notification tap when app was killed/backgrounded
String? _pendingNotificationRoute;

String? get pendingNotificationRoute => _pendingNotificationRoute;

void clearPendingNotificationRoute() {
  _pendingNotificationRoute = null;
}

/// Model for notification settings persisted in Hive
class NotificationSettings {
  final bool morningEnabled;
  final bool eveningEnabled;
  final bool tasbeehEnabled;
  final int morningHour;
  final int morningMinute;
  final int eveningHour;
  final int eveningMinute;

  NotificationSettings({
    this.morningEnabled = true,
    this.eveningEnabled = true,
    this.tasbeehEnabled = false,
    this.morningHour = AppConstants.defaultMorningHour,
    this.morningMinute = AppConstants.defaultMorningMinute,
    this.eveningHour = AppConstants.defaultEveningHour,
    this.eveningMinute = AppConstants.defaultEveningMinute,
  });

  Map<String, dynamic> toMap() => {
        'morningEnabled': morningEnabled,
        'eveningEnabled': eveningEnabled,
        'tasbeehEnabled': tasbeehEnabled,
        'morningHour': morningHour,
        'morningMinute': morningMinute,
        'eveningHour': eveningHour,
        'eveningMinute': eveningMinute,
      };

  factory NotificationSettings.fromMap(Map<dynamic, dynamic> map) {
    return NotificationSettings(
      morningEnabled: map['morningEnabled'] as bool? ?? true,
      eveningEnabled: map['eveningEnabled'] as bool? ?? true,
      tasbeehEnabled: map['tasbeehEnabled'] as bool? ?? false,
      morningHour: map['morningHour'] as int? ?? AppConstants.defaultMorningHour,
      morningMinute: map['morningMinute'] as int? ?? AppConstants.defaultMorningMinute,
      eveningHour: map['eveningHour'] as int? ?? AppConstants.defaultEveningHour,
      eveningMinute: map['eveningMinute'] as int? ?? AppConstants.defaultEveningMinute,
    );
  }

  NotificationSettings copyWith({
    bool? morningEnabled,
    bool? eveningEnabled,
    bool? tasbeehEnabled,
    int? morningHour,
    int? morningMinute,
    int? eveningHour,
    int? eveningMinute,
  }) {
    return NotificationSettings(
      morningEnabled: morningEnabled ?? this.morningEnabled,
      eveningEnabled: eveningEnabled ?? this.eveningEnabled,
      tasbeehEnabled: tasbeehEnabled ?? this.tasbeehEnabled,
      morningHour: morningHour ?? this.morningHour,
      morningMinute: morningMinute ?? this.morningMinute,
      eveningHour: eveningHour ?? this.eveningHour,
      eveningMinute: eveningMinute ?? this.eveningMinute,
    );
  }
}

/// Service for managing local scheduled notifications
///
/// UNIFIED service — the single source of truth for all notifications.
/// Use via singleton: NotificationService()
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Expose the underlying plugin for external services (e.g. prayer notifications).
  static FlutterLocalNotificationsPlugin get plugin => _instance._plugin;

  static const String _settingsBoxName = 'notification_settings';
  static const String _settingsKey = 'settings';

  bool _initialized = false;
  Box<Map>? _settingsBox;

  // ── Init ──

  /// Initialize timezone data and notification plugin.
  /// Safe to call multiple times — idempotent.
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final local = DateTime.now().timeZoneName;
    try {
      tz.setLocalLocation(tz.getLocation(local));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _initialized = true;
  }

  /// One-shot: init + refresh saved schedule (permissions are lazy, requested on settings screen).
  /// Call from main.dart after Hive is ready.
  Future<void> initFull() async {
    try {
      await init();
      await refreshSchedule();
    } catch (e) {
      debugPrint('NotificationService.initFull error: $e');
    }
  }

  // ── Convenience static methods (used by settings_screen) ──

  /// Static convenience — requests POST_NOTIFICATIONS permission (Android 13+).
  static Future<bool> requestPermission() => _instance.requestPermissions();

  /// Static convenience — schedule morning adhkar at default 7:00.
  static Future<void> scheduleMorningAdhkar() =>
      _instance._scheduleMorning(AppConstants.defaultMorningHour, AppConstants.defaultMorningMinute);

  /// Static convenience — schedule evening adhkar at default 18:00.
  static Future<void> scheduleEveningAdhkar() =>
      _instance._scheduleEvening(AppConstants.defaultEveningHour, AppConstants.defaultEveningMinute);

  /// Static convenience — schedule 3 tasbeeh reminders.
  static Future<void> scheduleRandomTasbeeh() => _instance._scheduleRandomTasbeeh();

  /// Static convenience — cancel morning adhkar.
  static Future<void> cancelMorningAdhkar() =>
      _instance._cancelMorning();

  /// Static convenience — cancel evening adhkar.
  static Future<void> cancelEveningAdhkar() =>
      _instance._cancelEvening();

  /// Static convenience — cancel tasbeeh reminders.
  static Future<void> cancelRandomTasbeeh() =>
      _instance._cancelRandomTasbeeh();

  /// Static convenience — cancel all notifications.
  static Future<void> cancelAllNotifications() =>
      _instance._plugin.cancelAll();

  // ── Notification tap handler ──

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    if (payload == AppConstants.payloadMorning) {
      _pendingNotificationRoute =
          '${AppConstants.routeAdhkar}/${AppConstants.payloadMorning}';
    } else if (payload == AppConstants.payloadEvening) {
      _pendingNotificationRoute =
          '${AppConstants.routeAdhkar}/${AppConstants.payloadEvening}';
    }
  }

  // ── Permissions ──

  /// Request runtime permissions (Android 13+ POST_NOTIFICATIONS).
  Future<bool> requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Open app settings for exact alarm permission (Android 12+).
  Future<bool> requestExactAlarmPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final enabled = await androidPlugin.requestExactAlarmsPermission();
      return enabled ?? false;
    }
    return true;
  }

  /// Check if exact alarm permission is granted
  Future<bool> get canScheduleExactNotifications async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      return enabled ?? false;
    }
    return true;
  }

  // ── Hive Settings ──

  Future<Box<Map>> _getBox() async {
    _settingsBox ??= await Hive.openBox<Map>(_settingsBoxName);
    return _settingsBox!;
  }

  Future<NotificationSettings> loadSettings() async {
    final box = await _getBox();
    final map = box.get(_settingsKey);
    if (map == null) return NotificationSettings();
    return NotificationSettings.fromMap(map);
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    final box = await _getBox();
    await box.put(_settingsKey, settings.toMap());
    await _applySettings(settings);
  }

  // ── Scheduling ──

  /// Apply settings: schedule or cancel notifications accordingly.
  Future<void> _applySettings(NotificationSettings settings) async {
    if (settings.morningEnabled) {
      await _scheduleMorning(settings.morningHour, settings.morningMinute);
    } else {
      await _cancelMorning();
    }

    if (settings.eveningEnabled) {
      await _scheduleEvening(settings.eveningHour, settings.eveningMinute);
    } else {
      await _cancelEvening();
    }

    if (settings.tasbeehEnabled) {
      await _scheduleRandomTasbeeh();
    } else {
      await _cancelRandomTasbeeh();
    }
  }

  /// Schedule or re-schedule morning notification.
  Future<void> _scheduleMorning(int hour, int minute) async {
    await _cancelMorning();

    final adhkarList = await _loadMorningAdhkar();
    if (adhkarList.isEmpty) return;

    final random = Random();
    final dhikr = adhkarList[random.nextInt(adhkarList.length)];

    await _zonedDailySchedule(
      id: AppConstants.notifMorningId.hashCode,
      title: '🌅 ذكر الصباح',
      body: _truncate(dhikr.arabic, 120),
      payload: AppConstants.payloadMorning,
      hour: hour,
      minute: minute,
    );
  }

  /// Schedule or re-schedule evening notification.
  Future<void> _scheduleEvening(int hour, int minute) async {
    await _cancelEvening();

    final adhkarList = await _loadEveningAdhkar();
    if (adhkarList.isEmpty) return;

    final random = Random();
    final dhikr = adhkarList[random.nextInt(adhkarList.length)];

    await _zonedDailySchedule(
      id: AppConstants.notifEveningId.hashCode,
      title: '🌇 ذكر المساء',
      body: _truncate(dhikr.arabic, 120),
      payload: AppConstants.payloadEvening,
      hour: hour,
      minute: minute,
    );
  }

  /// Schedule 3 tasbeeh reminders throughout the day.
  Future<void> _scheduleRandomTasbeeh() async {
    await _cancelRandomTasbeeh();

    final reminders = [
      _TasbeehReminder(10, 0, 'سبّح الله في الصباح 🌅'),
      _TasbeehReminder(14, 0, 'اذكر الله — سبحان الله وبحمده ☀️'),
      _TasbeehReminder(20, 0, 'أستغفر الله العظيم 🌙'),
    ];

    for (int i = 0; i < reminders.length; i++) {
      final r = reminders[i];
      await _zonedDailySchedule(
        id: '${AppConstants.notifRandomId}_$i'.hashCode,
        title: 'تذكير بالتسبيح 📿',
        body: r.body,
        payload: 'tasbeeh',
        hour: r.hour,
        minute: r.minute,
      );
    }
  }

  Future<void> _zonedDailySchedule({
    required int id,
    required String title,
    required String body,
    required String payload,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      AppConstants.notifChannelId,
      AppConstants.notifChannelName,
      channelDescription: AppConstants.notifChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body),
      category: AndroidNotificationCategory.reminder,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } on Exception catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  Future<void> _cancelMorning() async {
    await _plugin.cancel(AppConstants.notifMorningId.hashCode);
  }

  Future<void> _cancelEvening() async {
    await _plugin.cancel(AppConstants.notifEveningId.hashCode);
  }

  Future<void> _cancelRandomTasbeeh() async {
    for (int i = 0; i < 3; i++) {
      await _plugin.cancel('${AppConstants.notifRandomId}_$i'.hashCode);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Cancel all and re-schedule based on saved settings (call on app start).
  Future<void> refreshSchedule() async {
    final settings = await loadSettings();
    await _applySettings(settings);
  }

  // ── Data helpers ──

  Future<List<AdhkarModel>> _loadMorningAdhkar() async {
    try {
      final repo = AdhkarRepository();
      return await repo.loadMorningAdhkar();
    } catch (_) {
      return [];
    }
  }

  Future<List<AdhkarModel>> _loadEveningAdhkar() async {
    try {
      final repo = AdhkarRepository();
      return await repo.loadEveningAdhkar();
    } catch (_) {
      return [];
    }
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }
}

class _TasbeehReminder {
  final int hour;
  final int minute;
  final String body;

  _TasbeehReminder(this.hour, this.minute, this.body);
}
