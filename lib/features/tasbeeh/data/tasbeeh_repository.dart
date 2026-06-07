import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

/// Model for a single tasbeeh session
class TasbeehSession {
  final String date; // yyyy-MM-dd
  final int count;
  final String dhikr;
  final int timestamp;

  TasbeehSession({
    required this.date,
    required this.count,
    required this.dhikr,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'count': count,
        'dhikr': dhikr,
        'timestamp': timestamp,
      };

  factory TasbeehSession.fromMap(Map<dynamic, dynamic> map) => TasbeehSession(
        date: map['date'] as String,
        count: map['count'] as int,
        dhikr: map['dhikr'] as String,
        timestamp: map['timestamp'] as int,
      );
}

/// Repository for tasbeeh statistics backed by Hive
class TasbeehRepository {
  static const String _boxName = 'tasbeeh_stats';
  static const String _lastOpenKey = '_last_open_date';
  static const String _dailyCountKey = '_daily_count';
  static const String _dailyDhikrKey = '_daily_dhikr';

  late Box<Map> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox<Map>(_boxName);
    _initialized = true;
  }

  /// Save a completed session to history
  Future<void> saveSession({
    required int count,
    required String dhikr,
  }) async {
    await init();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final session = TasbeehSession(
      date: dateStr,
      count: count,
      dhikr: dhikr,
      timestamp: now.millisecondsSinceEpoch,
    );
    final key = '${dateStr}_${now.millisecondsSinceEpoch}';
    await _box.put(key, session.toMap());
  }

  /// Accumulate daily count without creating a new history entry
  /// Used while counting so we can show today's running total
  Future<void> accumulateDaily({required int count, required String dhikr}) async {
    await init();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final todayKey = '${dateStr}_$_dailyCountKey';
    final dhikrKey = '${dateStr}_$_dailyDhikrKey';

    final existing = _box.get(todayKey);
    final current = (existing?['count'] as int?) ?? 0;
    await _box.put(todayKey, {'count': current + count, 'dhikr': dhikr});
    await _box.put(dhikrKey, {'dhikr': dhikr});
  }

  /// Clear accumulated daily counters for the given date
  Future<void> clearDailyAccumulated(String dateStr) async {
    await init();
    await _box.delete('${dateStr}_$_dailyCountKey');
    await _box.delete('${dateStr}_$_dailyDhikrKey');
  }

  /// Get total count for a specific date (history + accumulated)
  Future<int> getTotalForDate(String dateStr) async {
    await init();
    int total = 0;

    // Sum history sessions for this date
    for (final entry in _box.toMap().entries) {
      if (entry.key.startsWith('_')) continue; // skip meta keys
      final map = entry.value;
      if (map['date'] == dateStr) {
        total += (map['count'] as int?) ?? 0;
      }
    }

    // Add accumulated if it's today
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (dateStr == todayStr) {
      final acc = _box.get('${dateStr}_$_dailyCountKey');
      total += (acc?['count'] as int?) ?? 0;
    }

    return total;
  }

  /// Get today's total count
  Future<int> getTodayTotal() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return getTotalForDate(today);
  }

  /// Get this week's daily totals (last 7 days)
  Future<Map<String, int>> getWeeklyStats() async {
    await init();
    final result = <String, int>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      result[dateStr] = await getTotalForDate(dateStr);
    }
    return result;
  }

  /// Get this month's daily totals
  Future<Map<String, int>> getMonthlyStats() async {
    await init();
    final result = <String, int>{};
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(now.year, now.month, i);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      result[dateStr] = await getTotalForDate(dateStr);
    }
    return result;
  }

  /// Check if we crossed midnight since last open.
  /// If yes, archive previous daily accumulated into a session and clear it.
  Future<bool> checkAndResetDaily() async {
    await init();
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final lastOpen = _box.get(_lastOpenKey)?['date'] as String?;
    await _box.put(_lastOpenKey, {'date': todayStr});

    if (lastOpen != null && lastOpen != todayStr) {
      // Day changed: archive the old accumulated count as a session
      final acc = _box.get('${lastOpen}_$_dailyCountKey');
      final dhikr = _box.get('${lastOpen}_$_dailyDhikrKey')?['dhikr'] as String? ?? 'سُبْحَانَ اللَّهِ';
      final count = (acc?['count'] as int?) ?? 0;
      if (count > 0) {
        final session = TasbeehSession(
          date: lastOpen,
          count: count,
          dhikr: dhikr,
          timestamp: DateTime.parse(lastOpen).millisecondsSinceEpoch,
        );
        await _box.put('${lastOpen}_${DateTime.now().millisecondsSinceEpoch}', session.toMap());
      }
      await clearDailyAccumulated(lastOpen);
      return true; // did reset
    }
    return false;
  }

  /// Get the last opened date
  String? getLastOpenDate() {
    if (!_initialized) return null;
    return _box.get(_lastOpenKey)?['date'] as String?;
  }
}

// Global repository instance
final tasbeehRepository = TasbeehRepository();
