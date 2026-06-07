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

  Future<List<AdhkarModel>> loadAllAdhkar() async {
    final morning = await loadMorningAdhkar();
    final evening = await loadEveningAdhkar();
    final afterPrayer = await loadAfterPrayerAdhkar();
    return [...morning, ...evening, ...afterPrayer];
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
        key: 'home',
        name: 'أدعية المنزل',
        icon: '🏠',
        description: 'أدعية دخول وخروج المنزل',
      ),
      CategoryModel(
        key: 'mosque',
        name: 'أدعية المسجد',
        icon: '🕌',
        description: 'أدعية دخول وخروج المسجد',
      ),
      CategoryModel(
        key: 'eating',
        name: 'أدعية الأكل',
        icon: '🍽️',
        description: 'الأدعية قبل وبعد الطعام',
      ),
      CategoryModel(
        key: 'drinking',
        name: 'أدعية الشرب',
        icon: '💧',
        description: 'أدعية الشرب',
      ),
      CategoryModel(
        key: 'dress',
        name: 'أدعية اللباس',
        icon: '👕',
        description: 'أدعية اللباس والخلع',
      ),
      CategoryModel(
        key: 'travel',
        name: 'أدعية السفر',
        icon: '🚗',
        description: 'الأدعية عند السفر',
      ),
      CategoryModel(
        key: 'rain',
        name: 'أدعية المطر',
        icon: '🌧️',
        description: 'الأدعية عند نزول المطر',
      ),
      CategoryModel(
        key: 'thunder',
        name: 'الرعد والبرق',
        icon: '⛈️',
        description: 'الدعاء عند سماع الرعد',
      ),
      CategoryModel(
        key: 'wind',
        name: 'الرياح',
        icon: '💨',
        description: 'الدعاء عند هبوب الرياح',
      ),
      CategoryModel(
        key: 'mirror',
        name: 'النظر في المرآة',
        icon: '🪞',
        description: 'الدعاء عند النظر في المرآة',
      ),
      CategoryModel(
        key: 'sneeze',
        name: 'العطاس',
        icon: '🤧',
        description: 'أدعية العطاس',
      ),
      CategoryModel(
        key: 'anger',
        name: 'الغضب',
        icon: '😤',
        description: 'الدعاء عند الغضب',
      ),
      CategoryModel(
        key: 'distress',
        name: 'الكرب والهم',
        icon: '😢',
        description: 'أدعية تفريج الكرب',
      ),
      CategoryModel(
        key: 'bathroom',
        name: 'دخول الخلاء',
        icon: '🚻',
        description: 'أدعية دخول وخروج الخلاء',
      ),
      CategoryModel(
        key: 'quran',
        name: 'من القرآن',
        icon: '📖',
        description: 'أدعية من القرآن الكريم',
      ),
      CategoryModel(
        key: 'deceased',
        name: 'الموتى',
        icon: '🕊️',
        description: 'أدعية للموتى',
      ),
      CategoryModel(
        key: 'sickness',
        name: 'المرض',
        icon: '🏥',
        description: 'أدعية عند المرض',
      ),
      CategoryModel(
        key: 'ruqyah',
        name: 'الرقية',
        icon: '🤲',
        description: 'أدعية الرقية الشرعية',
      ),
      CategoryModel(
        key: 'moon',
        name: 'رؤية الهلال',
        icon: '🌙',
        description: 'الدعاء عند رؤية الهلال',
      ),
      CategoryModel(
        key: 'fasting',
        name: 'الصيام',
        icon: '☪️',
        description: 'أدعية الصيام والإفطار',
      ),
      CategoryModel(
        key: 'children',
        name: 'الأولاد',
        icon: '👶',
        description: 'الدعاء للأولاد',
      ),
      CategoryModel(
        key: 'meeting',
        name: 'المجلس',
        icon: '💬',
        description: 'أدعية المجلس وكفارته',
      ),
      CategoryModel(
        key: 'fajr',
        name: 'الفجر',
        icon: '🌅',
        description: 'الدعاء عند صلاة الفجر',
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
