import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_screen.dart';
import 'features/adhkar/adhkar_screen.dart';
import 'features/adhkar/adhkar_detail_screen.dart';
import 'features/duaa/duaa_screen.dart';
import 'features/tasbeeh/tasbeeh_screen.dart';
import 'features/settings/settings_screen.dart';
import 'core/constants/app_constants.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.routeHome,
    routes: [
      GoRoute(
        path: AppConstants.routeHome,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAdhkar,
        name: 'adhkar',
        builder: (context, state) => const AdhkarScreen(),
      ),
      GoRoute(
        path: '${AppConstants.routeAdhkar}/:category',
        name: 'adhkar_detail',
        builder: (context, state) => AdhkarDetailScreen(
          category: state.pathParameters['category'] ?? 'morning',
        ),
      ),
      GoRoute(
        path: AppConstants.routeDuaa,
        name: 'duaa',
        builder: (context, state) => const DuaaScreen(),
      ),
      GoRoute(
        path: AppConstants.routeTasbeeh,
        name: 'tasbeeh',
        builder: (context, state) => const TasbeehScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSettings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
