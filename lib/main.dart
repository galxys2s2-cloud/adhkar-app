import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/settings_screen.dart';
import 'shared/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  await Hive.openBox<String>('favorites');
  await Hive.openBox('prayer');
  await NotificationService.initialize();
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
