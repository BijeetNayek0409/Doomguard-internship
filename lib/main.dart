import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:doomguard/core/theme/app_theme.dart';
import 'package:doomguard/core/navigation/app_router.dart';
import 'firebase_options.dart';
import 'shared/services/real_usage_service.dart';
import 'shared/models/usage_state.dart';
import 'shared/models/timer_state.dart';
import 'shared/models/streak_state.dart';
import 'shared/models/settings_state.dart';
import 'shared/models/auth_state.dart';
import 'shared/models/privacy_state.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await NotificationService().initialize();

  final authState = AuthState();
  final privacyState = PrivacyState();

  runApp(DoomsGuard(authState: authState, privacyState: privacyState));
}

class DoomsGuard extends StatefulWidget {
  final AuthState authState;
  final PrivacyState privacyState;
  const DoomsGuard({
    super.key,
    required this.authState,
    required this.privacyState,
  });

  @override
  State<DoomsGuard> createState() => _DoomsGuardState();
}

class _DoomsGuardState extends State<DoomsGuard> {
  late final _router = createRouter(
    widget.authState,
    widget.privacyState,
  ); // created once, never recreated

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthState>.value(value: widget.authState),
        ChangeNotifierProvider<PrivacyState>.value(value: widget.privacyState),
        ChangeNotifierProvider<UsageState>(
          create: (_) {
            final service = RealUsageService();
            final state = UsageState(usageService: service);
            state.loadUsage();
            return state;
          },
        ),
        ChangeNotifierProvider<TimerState>(
          create: (_) => TimerState(),
        ),
        ChangeNotifierProvider<StreakState>(
          create: (_) => StreakState(),
        ),
        ChangeNotifierProvider<SettingsState>(
          create: (_) => SettingsState(),
        ),
      ],
      child: _StatsSyncBootstrapper(
        child: MaterialApp.router(
          title: 'DoomGuard',
          theme: AppTheme.darkTheme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

/// Watches AuthState for sign-in/out and pushes the resolved uid into
/// StreakState and TimerState so they can sync their stats to Firestore
/// (and hydrate once on first login per session, e.g. on a fresh install).
class _StatsSyncBootstrapper extends StatefulWidget {
  final Widget child;
  const _StatsSyncBootstrapper({required this.child});

  @override
  State<_StatsSyncBootstrapper> createState() => _StatsSyncBootstrapperState();
}

class _StatsSyncBootstrapperState extends State<_StatsSyncBootstrapper> {
  String? _lastSyncedUid;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final uid = authState.status == AuthStatus.authenticated
        ? authState.appUser?.uid
        : null;

    if (uid != _lastSyncedUid) {
      _lastSyncedUid = uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<StreakState>().setUid(uid);
        context.read<TimerState>().setUid(uid);
      });
    }

    return widget.child;
  }
}