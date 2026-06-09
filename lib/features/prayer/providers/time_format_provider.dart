import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provider that tracks whether prayer times should display in 12h format.
///
/// Persists the preference in the 'prayer' Hive box under the key
/// `time_format_12h`. Defaults to `false` (24h format).
final is12hFormatProvider = StateNotifierProvider<TimeFormatNotifier, bool>((ref) {
  return TimeFormatNotifier();
});

class TimeFormatNotifier extends StateNotifier<bool> {
  TimeFormatNotifier() : super(_loadInitial());

  static bool _loadInitial() {
    try {
      final box = Hive.box('prayer');
      return box.get('time_format_12h', defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  void toggle() {
    state = !state;
    _persist(state);
  }

  void set(bool value) {
    state = value;
    _persist(value);
  }

  void _persist(bool value) {
    try {
      Hive.box('prayer').put('time_format_12h', value);
    } catch (_) {
      // Silently fail — the user's preference still works for this session.
    }
  }
}
