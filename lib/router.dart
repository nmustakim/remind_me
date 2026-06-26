import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/reminder/presentation/reminder_overlay_screen.dart';
import 'features/reminder/presentation/home_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/themes/presentation/themes_screen.dart';
import 'features/messages/presentation/messages_screen.dart';
import 'shared/presentation/main_shell.dart';
import 'core/storage/hive_storage.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: HiveStorage.isOnboardingComplete() ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/themes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ThemesScreen(),
            ),
          ),
          GoRoute(
            path: '/messages',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MessagesScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/reminder',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            child: ReminderOverlayScreen(
              themeId: extra?['themeId'] as String? ?? 'aurora',
              message: extra?['message'] as String? ?? 'Time to take a break.',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          );
        },
      ),
    ],
  );
});
