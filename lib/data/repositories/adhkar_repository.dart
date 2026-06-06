import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/adhkar_model.dart';

class AdhkarRepository {
  List<AdhkarModel>? _morningAdhkar;
  List<AdhkarModel>? _eveningAdhkar;
  List<AdhkarModel>? _afterPrayerAdhkar;
  List<DuaaModel>? _duaaList;

  Future<List<AdhkarModel>> loadMorningAdhkar() async {
    if (_morningAdhkar != null) return _morningAdhkar!;
    final jsonString = await rootBundle.loadString(
      'lib/data/json/morning_adhkar.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    _morningAdhkar = jsonList
        .map((e) => AdhkarModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _morningAdhkar!;
  }

  Future<List<AdhkarModel>> loadEveningAdhkar() async {
    if (_eveningAdhkar != null) return _eveningAdhkar!;
    final jsonString = await rootBundle.loadString(
      'lib/data/json/evening_adhkar.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    _eveningAdhkar = jsonList
        .map((e) => AdhkarModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _eveningAdhkar!;
  }

  Future<List<AdhkarModel>> loadAfterPrayerAdhkar() async {
    if (_afterPrayerAdhkar != null) return _afterPrayerAdhkar!;
    final jsonString = await rootBundle.loadString(
      'lib/data/json/after_prayer_adhkar.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    _afterPrayerAdhkar = jsonList
        .map((e) => AdhkarModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _afterPrayerAdhkar!;
  }

  Future<List<DuaaModel>> loadDuaaList() async {
    if (_duaaList != null) return _duaaList!;
    final jsonString =
        await rootBundle.loadString('lib/data/json/duaa.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    _duaaList = jsonList
        .map((e) => DuaaModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _duaaList!;
  }

  Future<List<AdhkarModel>> loadByCategory(String category) async {
    switch (category) {
      case 'morning':
        return loadMorningAdhkar();
      case 'evening':
        return loadEveningAdhkar();
      case 'after_prayer':
        return loadAfterPrayerAdhkar();
      default:
        return loadMorningAdhkar();
    }
  }

  List<CategoryModel> getAdhkarCategories() {
    return [
      CategoryModel(
        key: 'morning',
        name: 'أذكار الصباح',
        icon: '🌅',
        description: 'أذكار الصباح من الكتاب والسنة',
      ),
      CategoryModel(
        key: 'evening',
        name: 'أذكار المساء',
        icon: '🌇',
        description: 'أذكار المساء من الكتاب والسنة',
      ),
      CategoryModel(
        key: 'after_prayer',
        name: 'أذكار بعد الصلاة',
        icon: '🕌',
        description: 'الأذكار بعد الصلوات المفروضة',
      ),
    ];
  }

  List<CategoryModel> getDuaaCategories() {
    return [
      CategoryModel(
        key: 'sleep',
        name: 'أدعية النوم',
        icon: '🌙',
        description: 'الأدعية قبل النوم',
      ),
      CategoryModel(
        key: 'waking',
        name: 'أدعية الاستيقاظ',
        icon: '☀️',
        description: 'الأدعية عند الاستيقاظ',
      ),
      CategoryModel(
        key: 'eating',
        name: 'أدعية الأكل والشرب',
        icon: '🍽️',
        description: 'الأدعية قبل وبعد الطعام',
      ),
      CategoryModel(
        key: 'travel',
        name: 'أدعية السفر',
        icon: '🚗',
        description: 'الأدعية عند السفر',
      ),
      CategoryModel(
        key: 'general',
        name: 'أدعية عامة',
        icon: '🤲',
        description: 'أدعية مأثورة متنوعة',
      ),
    ];
  }
}

final adhkarRepositoryProvider = Provider<AdhkarRepository>((ref) {
  return AdhkarRepository();
});
