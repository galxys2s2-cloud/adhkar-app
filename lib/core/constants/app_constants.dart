class AppConstants {
  AppConstants._();

  // Routes
  static const String routeHome = '/';
  static const String routeAdhkar = '/adhkar';
  static const String routeDuaa = '/duaa';
  static const String routeTasbeeh = '/tasbeeh';
  static const String routeSettings = '/settings';
  static const String routeFavorites = '/favorites';

  // Adhkar categories
  static const String categoryMorning = 'morning';
  static const String categoryEvening = 'evening';
  static const String categoryAfterPrayer = 'after_prayer';

  // Duaa categories
  static const String duaaSleep = 'sleep';
  static const String duaaWaking = 'waking';
  static const String duaaEating = 'eating';
  static const String duaaTravel = 'travel';
  static const String duaaGeneral = 'general';

  // Notifications
  static const String notifChannelId = 'adhkar_channel';
  static const String notifChannelName = 'الأذكار';
  static const String notifChannelDesc = 'تذكيرات يومية بأذكار الصباح والمساء';
  static const String notifMorningId = 'morning_adhkar';
  static const String notifEveningId = 'evening_adhkar';
  static const String notifRandomId = 'random_tasbeeh';
  static const String payloadMorning = 'morning';
  static const String payloadEvening = 'evening';
  static const int defaultMorningHour = 7;
  static const int defaultMorningMinute = 0;
  static const int defaultEveningHour = 18;
  static const int defaultEveningMinute = 0;

  // Tasbeeh defaults
  static const int tasbeehTarget = 33;
  static const int tasbeehMaxPresets = 5;

  // App info
  static const String appName = 'الأذكار';
  static const String appVersion = '2.0.0';
}
