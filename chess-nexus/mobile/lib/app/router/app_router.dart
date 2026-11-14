import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../../features/home/presentation/editorial_home_screen.dart';
import '../../features/gameplay/presentation/battle_arena_screen.dart';
import '../../features/academy/presentation/tactics_academy_screen.dart';
import '../../features/competition/presentation/competition_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/analysis/presentation/analysis_studio_screen.dart';
import '../../features/game_vault/presentation/game_vault_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Primary ShellRoute with Bottom Navigation Bar
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: EditorialHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/play',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BattleArenaScreen(),
          ),
        ),
        GoRoute(
          path: '/learn',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TacticsAcademyScreen(),
          ),
        ),
        GoRoute(
          path: '/compete',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CompetitionScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),

    // Secondary Full-screen routes (Above Bottom Bar)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/analysis',
      builder: (context, state) => const AnalysisStudioScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/vault',
      builder: (context, state) => const GameVaultScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int currentIndex = _calculateSelectedIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: NexusColors.obsidian,
          border: const Border(
            top: BorderSide(color: NexusColors.emerald, width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: NexusColors.emerald,
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: NexusColors.mintAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                );
              }
              return const TextStyle(
                color: NexusColors.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: NexusColors.mintAccent, size: 24);
              }
              return const IconThemeData(color: NexusColors.secondaryText, size: 22);
            }),
          ),
          child: NavigationBar(
            backgroundColor: NexusColors.obsidian,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onItemTapped(index, context),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.sports_esports_outlined),
                selectedIcon: Icon(Icons.sports_esports),
                label: 'Play',
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: 'Learn',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: 'Compete',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(String location) {
    if (location.startsWith('/play')) return 1;
    if (location.startsWith('/learn')) return 2;
    if (location.startsWith('/compete')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; // Default to home
  }

  static void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/play');
        break;
      case 2:
        context.go('/learn');
        break;
      case 3:
        context.go('/compete');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

