import 'package:hive_flutter/hive_flutter.dart';
import 'prayer_times_model.dart';

/// Repository that manages prayer times with Hive caching.
class PrayerRepository {
  final Box _box;

  PrayerRepository(this._box);

  /// Save prayer times to cache.
  Future<void> cacheTimings({
    required String city,
    required PrayerTimesModel timings,
    required int method,
  }) async {
    await _box.put('prayer_${city}_m$method', {
      'date': DateTime.now().toIso8601String(),
      'data': timings.toJson(),
    });
  }

  /// Load cached prayer times if fresh (same day).
  PrayerTimesModel? loadCached({
    required String city,
    required int method,
  }) {
    final cached = _box.get('prayer_${city}_m$method');
    if (cached == null) return null;

    final cachedDate = DateTime.parse(cached['date'] as String);
    final now = DateTime.now();
    final isToday = cachedDate.year == now.year &&
        cachedDate.month == now.month &&
        cachedDate.day == now.day;

    if (!isToday) return null;

    // Reconstruct from cached data
    final data = cached['data'] as Map;
    return PrayerTimesModel(
      date: now,
      fajr: data['fajr'] as String,
      sunrise: data['sunrise'] as String,
      dhuhr: data['dhuhr'] as String,
      asr: data['asr'] as String,
      maghrib: data['maghrib'] as String,
      isha: data['isha'] as String,
    );
  }
}
