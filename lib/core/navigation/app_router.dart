// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/screen/dashboard_screen.dart';
import '../../features/timer/screen/timer_screen.dart';
import '../../features/stats/screen/stats_screen.dart';
import '../../features/streaks/screen/streaks_screen.dart';
import '../../features/settings/screen/settings_screen.dart';
import '../../features/auth/screen/login_screen.dart';
import '../../features/survey/screen/survey_screen.dart';
import '../../shared/models/auth_state.dart';
import '../../core/theme/app_theme.dart';

GoRouter createRouter(AuthState authState) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authState,
    redirect: (context, state) {
      final status = authState.status;
      final isFetching = authState.isFetchingUser;
      final loc = state.matchedLocation;
      final onLogin = loc == '/login';
      final onSurvey = loc == '/survey';

      // 1. Still initializing — don't redirect yet
      if (status == AuthStatus.unknown) return null;

      // 2. Firestore fetch in progress — hold position, prevent loop
      if (isFetching) return null;

      final loggedIn = status == AuthStatus.authenticated;

      // 3. Not logged in → send to login
      if (!loggedIn) return onLogin ? null : '/login';

      final surveyDone = authState.appUser?.surveyCompleted ?? false;

      // 4. Logged in but survey not done → send to survey
      if (!surveyDone && !onSurvey) return '/survey';

      // 5. Logged in + survey done, but still on login or survey → send to home
      if (surveyDone && (onLogin || onSurvey)) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/survey',
        builder: (context, state) => const SurveyScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ScaffoldWithNavBar(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/timer',
              builder: (context, state) => const TimerScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/streaks',
              builder: (context, state) => const StreaksScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
}

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell shell;
  const ScaffoldWithNavBar({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DG.bg,
      body: shell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: DG.bg,
        indicatorColor: DG.primary.withOpacity(0.15),
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer_rounded),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department_rounded),
            label: 'Streaks',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}