import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provider that tracks the selected city for prayer times.
///
/// Persists the preference in the 'prayer' Hive box under the key
/// `last_city`. Defaults to `'بيروت'`.
final prayerCityProvider = StateNotifierProvider<PrayerCityNotifier, String>((ref) {
  return PrayerCityNotifier();
});

class PrayerCityNotifier extends StateNotifier<String> {
  PrayerCityNotifier() : super(_loadInitial());

  static String _loadInitial() {
    try {
      final box = Hive.box('prayer');
      return box.get('last_city', defaultValue: 'بيروت') as String;
    } catch (_) {
      return 'بيروت';
    }
  }

  void set(String value) {
    state = value;
    _persist(value);
  }

  void _persist(String value) {
    try {
      Hive.box('prayer').put('last_city', value);
    } catch (_) {
      // Silently fail — the user's preference still works for this session.
    }
  }
}

/// Provider that tracks the selected calculation method ID for prayer times.
///
/// Persists the preference in the 'prayer' Hive box under the key
/// `last_method`. Defaults to `3` (Muslim World League).
final prayerMethodProvider = StateNotifierProvider<PrayerMethodNotifier, int>((ref) {
  return PrayerMethodNotifier();
});

class PrayerMethodNotifier extends StateNotifier<int> {
  PrayerMethodNotifier() : super(_loadInitial());

  static int _loadInitial() {
    try {
      final box = Hive.box('prayer');
      return box.get('last_method', defaultValue: 3) as int;
    } catch (_) {
      return 3;
    }
  }

  void set(int value) {
    state = value;
    _persist(value);
  }

  void _persist(int value) {
    try {
      Hive.box('prayer').put('last_method', value);
    } catch (_) {
      // Silently fail — the user's preference still works for this session.
    }
  }
}

/// Provider that tracks the selected calculation method name for prayer times.
///
/// Persists the preference in the 'prayer' Hive box under the key
/// `last_method_name`. Defaults to `'Muslim World League'`.
final prayerMethodNameProvider = StateNotifierProvider<PrayerMethodNameNotifier, String>((ref) {
  return PrayerMethodNameNotifier();
});

class PrayerMethodNameNotifier extends StateNotifier<String> {
  PrayerMethodNameNotifier() : super(_loadInitial());

  static String _loadInitial() {
    try {
      final box = Hive.box('prayer');
      return box.get('last_method_name', defaultValue: 'Muslim World League') as String;
    } catch (_) {
      return 'Muslim World League';
    }
  }

  void set(String value) {
    state = value;
    _persist(value);
  }

  void _persist(String value) {
    try {
      Hive.box('prayer').put('last_method_name', value);
    } catch (_) {
      // Silently fail — the user's preference still works for this session.
    }
  }
}
