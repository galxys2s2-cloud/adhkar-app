import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritesState {
  final Set<String> adhkarIds;
  final Set<String> duaaIds;

  const FavoritesState({
    this.adhkarIds = const {},
    this.duaaIds = const {},
  });

  FavoritesState copyWith({
    Set<String>? adhkarIds,
    Set<String>? duaaIds,
  }) {
    return FavoritesState(
      adhkarIds: adhkarIds ?? this.adhkarIds,
      duaaIds: duaaIds ?? this.duaaIds,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  static const String _boxName = 'favorites';
  static const String _adhkarKey = 'adhkar_ids';
  static const String _duaaKey = 'duaa_ids';

  late final Box<String> _box;

  FavoritesNotifier() : super(const FavoritesState()) {
    _init();
  }

  void _init() {
    _box = Hive.box<String>(_boxName);
    final adhkarIds = _decodeList(_box.get(_adhkarKey));
    final duaaIds = _decodeList(_box.get(_duaaKey));
    state = FavoritesState(
      adhkarIds: adhkarIds.toSet(),
      duaaIds: duaaIds.toSet(),
    );
  }

  List<String> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  void _saveAdhkar() {
    _box.put(_adhkarKey, jsonEncode(state.adhkarIds.toList()));
  }

  void _saveDuaa() {
    _box.put(_duaaKey, jsonEncode(state.duaaIds.toList()));
  }

  void toggleAdhkar(String id) {
    final current = Set<String>.from(state.adhkarIds);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    state = state.copyWith(adhkarIds: current);
    _saveAdhkar();
  }

  void toggleDuaa(String id) {
    final current = Set<String>.from(state.duaaIds);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    state = state.copyWith(duaaIds: current);
    _saveDuaa();
  }

  bool isAdhkarFavorite(String id) => state.adhkarIds.contains(id);
  bool isDuaaFavorite(String id) => state.duaaIds.contains(id);

  int get totalCount => state.adhkarIds.length + state.duaaIds.length;
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier();
});
