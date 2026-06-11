import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/prayer/providers/prayer_notification_provider.dart';
import 'features/prayer/providers/prayer_provider.dart';
import 'features/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  await Hive.openBox<String>('favorites');
  await Hive.openBox('prayer');
  await NotificationService().initFull();
  runApp(
    const ProviderScope(
      child: AdhkarApp(),
    ),
  );
}

class AdhkarApp extends ConsumerWidget {
  const AdhkarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    // Auto-schedule prayer notifications on startup if toggle is ON
    Future.microtask(() async {
      try {
        final enabled = ref.read(prayerNotificationsEnabledProvider);
        if (enabled) {
          final timings = await ref.read(prayerTimingsProvider.future);
          final service = ref.read(prayerNotificationServiceProvider);
          await service.schedulePrayerNotifications(timings);
        }
      } catch (_) {
        // City not set or API unavailable — user will trigger when opening prayer screen
      }
    });

    return MaterialApp.router(
      title: 'الأذكار',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: ref.read(appRouterProvider),
    );
  }
}
