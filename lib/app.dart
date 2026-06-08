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
import 'features/tasbeeh/presentation/stats_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/favorites/presentation/favorites_screen.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'features/prayer/presentation/prayer_screen.dart';

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
            pageBuilder: (context, state) => _buildTransitionPage(
              const HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppConstants.routeFavorites,
            name: 'favorites',
            pageBuilder: (context, state) => _buildTransitionPage(
              const FavoritesScreen(),
            ),
          ),
          GoRoute(
            path: AppConstants.routeSettings,
            name: 'settings',
            pageBuilder: (context, state) => _buildTransitionPage(
              const SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.routeAdhkar,
        name: 'adhkar',
        pageBuilder: (context, state) => _buildTransitionPage(
          const AdhkarScreen(),
        ),
      ),
      GoRoute(
        path: '${AppConstants.routeAdhkar}/:category',
        name: 'adhkar_detail',
        pageBuilder: (context, state) => _buildTransitionPage(
          AdhkarDetailScreen(
            category: state.pathParameters['category'] ?? 'morning',
          ),
        ),
      ),
      GoRoute(
        path: AppConstants.routeDuaa,
        name: 'duaa',
        pageBuilder: (context, state) => _buildTransitionPage(
          const DuaaScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeTasbeeh,
        name: 'tasbeeh',
        pageBuilder: (context, state) => _buildTransitionPage(
          const TasbeehScreen(),
        ),
      ),
      GoRoute(
        path: '/tasbeeh/stats',
        name: 'tasbeeh_stats',
        pageBuilder: (context, state) => _buildTransitionPage(
          const StatsScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.routePrayer,
        name: 'prayer',
        pageBuilder: (context, state) => _buildTransitionPage(
          const PrayerScreen(),
        ),
      ),
    ],
  );
});

/// Builds a [CustomTransitionPage] with slide (from right, ~200ms interval)
/// + fade (0.0 to 1.0, ~300ms) using [Curves.easeInOutCubic].
CustomTransitionPage _buildTransitionPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.66, curve: Curves.easeInOutCubic),
        ),
      );

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
        ),
      );

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

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
      bottomNavigationBar: _AnimatedBottomNav(
        currentIndex: currentIndex,
        favCount: favCount,
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
      ),
    );
  }
}

class _AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final int favCount;
  final ValueChanged<int> onTap;

  const _AnimatedBottomNav({
    required this.currentIndex,
    required this.favCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final unselectedColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 3;
          final indicatorLeft = itemWidth * currentIndex +
              (itemWidth - 40) / 2;

          return Stack(
            children: [
              // Gold underline indicator — smoothly slides between items
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                bottom: 8,
                left: indicatorLeft,
                child: Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Nav items row
              Row(
                children: [
                  _buildItem(
                    0,
                    Icons.home_outlined,
                    Icons.home,
                    'الرئيسية',
                    unselectedColor,
                  ),
                  _buildItem(
                    1,
                    Icons.favorite_border,
                    Icons.favorite,
                    'المفضلة',
                    unselectedColor,
                    badge: favCount,
                  ),
                  _buildItem(
                    2,
                    Icons.settings_outlined,
                    Icons.settings,
                    'الإعدادات',
                    unselectedColor,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    Color unselectedColor, {
    int badge = 0,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.25 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: isSelected ? Curves.easeOutBack : Curves.easeInOutCubic,
              child: badge > 0 && index == 1
                  ? Badge(
                      isLabelVisible: true,
                      label: Text('$badge'),
                      child: Icon(
                        isSelected ? activeIcon : icon,
                        color: isSelected ? AppColors.gold : unselectedColor,
                        size: 24,
                      ),
                    )
                  : Icon(
                      isSelected ? activeIcon : icon,
                      color: isSelected ? AppColors.gold : unselectedColor,
                      size: 24,
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.gold : unselectedColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
