import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/gameplay/presentation/battle_arena_screen.dart';
import '../../features/game_vault/presentation/game_vault_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // 1. Primary Hero Screen: Voice-First Chess Arena
    GoRoute(
      path: '/',
      builder: (context, state) => const BattleArenaScreen(),
    ),

    // 2. Simple Previous Game History
    GoRoute(
      path: '/history',
      builder: (context, state) => const GameVaultScreen(),
    ),

    // 3. Settings (Sound, Voice & Appearance)
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
