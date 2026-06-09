import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/prayer_api_service.dart';
import '../data/prayer_repository.dart';
import '../data/prayer_times_model.dart';
import 'prayer_settings_provider.dart';

// Re-export Hive-backed city/method providers for convenience
export 'prayer_settings_provider.dart' show prayerCityProvider, prayerMethodProvider, prayerMethodNameProvider;

// --- Repository provider ---
final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepository(Hive.box('prayer'));
});

// --- API service provider ---
final prayerApiServiceProvider = Provider<PrayerApiService>((ref) {
  return PrayerApiService();
});

// --- Prayer times provider (async, depends on city + method) ---
final prayerTimingsProvider = FutureProvider<PrayerTimesModel>((ref) async {
  final city = ref.watch(prayerCityProvider);
  final method = ref.watch(prayerMethodProvider);
  final api = ref.read(prayerApiServiceProvider);
  final repo = ref.read(prayerRepositoryProvider);

  // Try cache first
  final cached = repo.loadCached(city: city, method: method);
  if (cached != null) return cached;

  // Fetch from API
  final timings = await api.fetchTimings(
    city: city,
    country: 'Lebanon',
    method: method,
  );

  // Cache for offline use
  await repo.cacheTimings(city: city, timings: timings, method: method);

  return timings;
});

// --- Auto-refresh every minute (for countdown) ---
final currentTimeProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});
