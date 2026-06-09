/// Utility for formatting prayer times between 24h and 12h formats.
class TimeFormatter {
  /// Converts a time string from 24h format (HH:mm) to 12h Arabic format.
  ///
  /// Examples:
  /// - `05:23` → `5:23 ص`
  /// - `12:00` → `12:00 م`
  /// - `21:30` → `9:30 م`
  static String to12h(String time24h) {
    final parts = time24h.split(':');
    if (parts.length != 2) return time24h;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];

    if (hour < 12) {
      if (hour == 0) {
        return '12:$minute ص';
      }
      return '$hour:$minute ص';
    } else {
      final displayHour = hour == 12 ? 12 : hour - 12;
      return '$displayHour:$minute م';
    }
  }

  /// If [use12h] is true, converts to Arabic 12h format; otherwise returns as-is.
  static String format(String time24h, {bool use12h = false}) {
    if (!use12h) return time24h;
    return to12h(time24h);
  }
}
