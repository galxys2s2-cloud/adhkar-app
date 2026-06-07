import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_colors.dart';
import 'features/home/home_screen.dart';
import 'features/adhkar/adhkar_screen.dart';
import 'features/adhkar/adhkar_detail_screen.dart';
import 'features/duaa/duaa_screen.dart';
import 'features/tasbeeh/tasbeeh_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/favorites/presentation/favorites_screen.dart';
import 'features/favorites/providers/favorites_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.routeHome,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return _MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppConstants.routeHome,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppConstants.routeFavorites,
            name: 'favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: AppConstants.routeSettings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
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
    ],
  );
});

class _MainScaffold extends ConsumerWidget {
  final Widget child;

  const _MainScaffold({required this.child});

  int _indexFromLocation(String location) {
    if (location == AppConstants.routeFavorites) return 1;
    if (location == AppConstants.routeSettings) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _indexFromLocation(location);
    final favCount = ref.watch(
      favoritesProvider.select((s) => s.totalCount),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppConstants.routeHome);
              break;
            case 1:
              context.go(AppConstants.routeFavorites);
              break;
            case 2:
              context.go(AppConstants.routeSettings);
              break;
          }
        },
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite_border),
            ),
            activeIcon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite),
            ),
            label: 'المفضلة',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
