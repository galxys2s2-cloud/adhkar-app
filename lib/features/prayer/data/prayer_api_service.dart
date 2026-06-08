import 'dart:convert';
import 'package:http/http.dart' as http;
import 'prayer_times_model.dart';

/// API service for fetching prayer times from Aladhan.com.
class PrayerApiService {
  static const _baseUrl = 'https://api.aladhan.com/v1';

  /// Calculation methods:
  /// 3 = Muslim World League
  /// 4 = Umm Al-Qura (Makkah)
  /// 5 = Egyptian General Authority
  /// 8 = Gulf (Dubai)
  /// 9 = Kuwait
  /// 10 = Qatar
  /// 11 = Majlis Ugama Islam Singapura
  /// 12 = Union of Islamic Organisations of France
  /// 13 = Diyanet İşleri Başkanlığı (Turkey)
  /// 14 = Spiritual Administration of Muslims of Russia
  /// 15 = Moonsighting Committee Worldwide
  /// 16 = Mecca (ISNA)
  static const Map<String, int> knownMethods = {
    'Muslim World League': 3,
    'Dar al-Fatwa (Lebanon)': 3, // Lebanon uses similar to MWL
    'Umm Al-Qura': 4,
    'Egyptian': 5,
    'ISNA': 16,
  };

  /// Fetch prayer times by city name.
  Future<PrayerTimesModel> fetchTimings({
    required String city,
    required String country,
    int method = 3,
  }) async {
    final uri = Uri.parse('$_baseUrl/timingsByCity').replace(
      queryParameters: {
        'city': city,
        'country': country,
        'method': '$method',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('فشل في تحميل مواقيت الصلاة (${response.statusCode})');
    }

    final decoded = json.decode(response.body);
    if (decoded['code'] != 200) {
      throw Exception(decoded['data'] ?? 'خطأ في الـ API');
    }

    return PrayerTimesModel.fromJson(decoded);
  }

  /// Fetch prayer times by GPS coordinates.
  Future<PrayerTimesModel> fetchTimingsByCoords({
    required double latitude,
    required double longitude,
    int method = 3,
  }) async {
    final uri = Uri.parse('$_baseUrl/timings').replace(
      queryParameters: {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'method': '$method',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('فشل في تحميل مواقيت الصلاة (${response.statusCode})');
    }

    final decoded = json.decode(response.body);
    if (decoded['code'] != 200) {
      throw Exception(decoded['data'] ?? 'خطأ في الـ API');
    }

    return PrayerTimesModel.fromJson(decoded);
  }
}
