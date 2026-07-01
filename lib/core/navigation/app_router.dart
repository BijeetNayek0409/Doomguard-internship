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
import '../../features/privacy/screen/privacy_policy_screen.dart';
import '../../shared/models/auth_state.dart';
import '../../shared/models/privacy_state.dart';
import '../../core/theme/app_theme.dart';

GoRouter createRouter(AuthState authState, PrivacyState privacyState) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: Listenable.merge([authState, privacyState]),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final onPrivacy = loc == '/privacy';

      // 0. Privacy state hasn't loaded from disk yet — hold position
      if (!privacyState.isLoaded) return null;

      // 1. Not yet accepted the privacy policy → force it first,
      //    before anything else (auth, survey, etc.)
      if (!privacyState.accepted) {
        return onPrivacy ? null : '/privacy';
      }

      // 2. Accepted but still sitting on the privacy screen → move on
      if (privacyState.accepted && onPrivacy) return '/login';

      final status = authState.status;
      final isFetching = authState.isFetchingUser;
      final onLogin = loc == '/login';
      final onSurvey = loc == '/survey';

      // 3. Still initializing — don't redirect yet
      if (status == AuthStatus.unknown) return null;

      // 4. Firestore fetch in progress — hold position, prevent loop
      if (isFetching) return null;

      final loggedIn = status == AuthStatus.authenticated;

      // 5. Not logged in → send to login
      if (!loggedIn) return onLogin ? null : '/login';

      final surveyDone = authState.appUser?.surveyCompleted ?? false;

      // 6. Logged in but survey not done → send to survey
      if (!surveyDone && !onSurvey) return '/survey';

      // 7. Logged in + survey done, but still on login or survey → send to home
      if (surveyDone && (onLogin || onSurvey)) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
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