import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';

/// Provider for notification settings (Hive-backed)
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(),
);

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final NotificationService _service = NotificationService();

  NotificationSettingsNotifier() : super(NotificationSettings()) {
    _load();
  }

  Future<void> _load() async {
    final settings = await _service.loadSettings();
    state = settings;
  }

  Future<void> save(NotificationSettings settings) async {
    state = settings;
    await _service.saveSettings(settings);
  }

  Future<void> toggleMorning(bool enabled) async {
    final updated = state.copyWith(morningEnabled: enabled);
    await save(updated);
  }

  Future<void> toggleEvening(bool enabled) async {
    final updated = state.copyWith(eveningEnabled: enabled);
    await save(updated);
  }

  Future<void> toggleTasbeeh(bool enabled) async {
    final updated = state.copyWith(tasbeehEnabled: enabled);
    await save(updated);
  }

  Future<void> setMorningTime(int hour, int minute) async {
    final updated = state.copyWith(morningHour: hour, morningMinute: minute);
    await save(updated);
  }

  Future<void> setEveningTime(int hour, int minute) async {
    final updated = state.copyWith(eveningHour: hour, eveningMinute: minute);
    await save(updated);
  }
}
