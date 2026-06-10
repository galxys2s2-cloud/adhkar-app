import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'prayer_times_model.dart';

/// API service for fetching prayer times from Aladhan.com.
class PrayerApiService {
  static const _mobileBaseUrl = 'https://api.aladhan.com/v1';
  static const _webBaseUrl = 'https://obsidian.meganet.live/prayer-proxy/v1';

  static String get _baseUrl => kIsWeb ? _webBaseUrl : _mobileBaseUrl;

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
}
