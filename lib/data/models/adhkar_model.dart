class AdhkarModel {
  final String id;
  final String category;
  final String arabic;
  final String? translation;
  final String? transliteration;
  final String reference;
  final int count;
  final bool hasBismillah;

  AdhkarModel({
    required this.id,
    required this.category,
    required this.arabic,
    this.translation,
    this.transliteration,
    required this.reference,
    this.count = 1,
    this.hasBismillah = false,
  });

  factory AdhkarModel.fromJson(Map<String, dynamic> json) {
    return AdhkarModel(
      id: json['id'] as String,
      category: json['category'] as String,
      arabic: json['arabic'] as String,
      translation: json['translation'] as String?,
      transliteration: json['transliteration'] as String?,
      reference: json['reference'] as String,
      count: (json['count'] as int?) ?? 1,
      hasBismillah: (json['has_bismillah'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'arabic': arabic,
      'translation': translation,
      'transliteration': transliteration,
      'reference': reference,
      'count': count,
      'has_bismillah': hasBismillah,
    };
  }
}

class CategoryModel {
  final String key;
  final String name;
  final String icon;
  final String description;

  CategoryModel({
    required this.key,
    required this.name,
    required this.icon,
    required this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      key: json['key'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
    );
  }
}

class DuaaModel {
  final String id;
  final String category;
  final String arabic;
  final String? translation;
  final String? transliteration;
  final String reference;
  final int count;
  final String? beforeAfter;

  DuaaModel({
    required this.id,
    required this.category,
    required this.arabic,
    this.translation,
    this.transliteration,
    required this.reference,
    this.count = 1,
    this.beforeAfter,
  });

  factory DuaaModel.fromJson(Map<String, dynamic> json) {
    return DuaaModel(
      id: json['id'] as String,
      category: json['category'] as String,
      arabic: json['arabic'] as String,
      translation: json['translation'] as String?,
      transliteration: json['transliteration'] as String?,
      reference: json['reference'] as String,
      count: (json['count'] as int?) ?? 1,
      beforeAfter: json['before_after'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'arabic': arabic,
      'translation': translation,
      'transliteration': transliteration,
      'reference': reference,
      'count': count,
      'before_after': beforeAfter,
    };
  }
}
