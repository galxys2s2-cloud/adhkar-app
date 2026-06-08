/// Represents prayer times for a single day.
class PrayerTimesModel {
  final DateTime date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  const PrayerTimesModel({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    return PrayerTimesModel(
      date: _parseDate(json['data']['date']['gregorian']['date']),
      fajr: timings['Fajr'],
      sunrise: timings['Sunrise'],
      dhuhr: timings['Dhuhr'],
      asr: timings['Asr'],
      maghrib: timings['Maghrib'],
      isha: timings['Isha'],
    );
  }

  static DateTime _parseDate(String gregorianDate) {
    final parts = gregorianDate.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  /// All prayer times as a map (Arabic name → time string like "05:23").
  Map<String, String> get allTimes => {
        'الفجر': fajr,
        'الشروق': sunrise,
        'الظهر': dhuhr,
        'العصر': asr,
        'المغرب': maghrib,
        'العشاء': isha,
      };

  /// Find the next prayer time as (name, DateTime) based on current time.
  MapEntry<String, DateTime>? nextPrayer([DateTime? now]) {
    now ??= DateTime.now();
    final prayers = {
      'الفجر': fajr,
      'الشروق': sunrise,
      'الظهر': dhuhr,
      'العصر': asr,
      'المغرب': maghrib,
      'العشاء': isha,
    };

    for (final entry in prayers.entries) {
      final timeParts = entry.value.split(':');
      final prayerTime = DateTime(
        now.year, now.month, now.day,
        int.parse(timeParts[0]), int.parse(timeParts[1]),
      );
      if (prayerTime.isAfter(now)) {
        return MapEntry(entry.key, prayerTime);
      }
    }

    // If no prayer today remains, return tomorrow's Fajr
    final fajrParts = fajr.split(':');
    final tomorrowFajr = DateTime(
      now.year, now.month, now.day + 1,
      int.parse(fajrParts[0]), int.parse(fajrParts[1]),
    );
    return MapEntry('الفجر', tomorrowFajr);
  }

  /// Duration until the next prayer.
  Duration durationUntilNext([DateTime? now]) {
    final next = nextPrayer(now);
    if (next == null) return Duration.zero;
    return next.value.difference(now ?? DateTime.now());
  }

  Map<String, dynamic> toJson() => {
        'fajr': fajr,
        'sunrise': sunrise,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      };
}
