
// lib/shared/services/limit_watcher_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'real_usage_service.dart';
import 'notification_service.dart';

// ── Default limits (used until user-configurable limits screen is built) ───

/// Per-app daily limit in minutes. Any app not listed uses [_defaultAppLimitMinutes].
const Map<String, int> _appLimits = {
  'com.instagram.android': 30,
  'com.zhiliaoapp.musically': 30,  // TikTok
  'com.facebook.katana': 30,       // Facebook
  'com.twitter.android': 30,
  'com.snapchat.android': 30,
  'com.reddit.frontpage': 45,
  'com.youtube.android': 60,
  'com.google.android.youtube': 60,
};

const int _defaultAppLimitMinutes = 60;

/// Total daily screen time goal in minutes (2 hours)
const int _totalDailyLimitMinutes = 120;

/// Continuous single-app session limit in minutes before nudging
const int _continuousSessionLimitMinutes = 30;

/// How often the watcher polls usage stats (while app is open)
const Duration _pollInterval = Duration(minutes: 1);

// ── Nudge cooldown keys (stored in SharedPreferences) ─────────────────────
// Prevents firing the same nudge repeatedly within a cooldown window.

const Duration _perAppNudgeCooldown = Duration(minutes: 15);
const Duration _continuousNudgeCooldown = Duration(minutes: 10);
const Duration _totalScreenTimeCooldown = Duration(minutes: 30);

class LimitWatcherService {
  static final LimitWatcherService _instance = LimitWatcherService._internal();
  factory LimitWatcherService() => _instance;
  LimitWatcherService._internal();

  final _usageService = RealUsageService();
  final _notificationService = NotificationService();

  Timer? _pollTimer;
  bool _running = false;

  /// Start the polling loop. Call this once from main.dart or after login.
  /// Safe to call multiple times — only starts one timer.
  void start() {
    if (_running) return;
    _running = true;
    debugPrint('LimitWatcherService: started');

    // Run once immediately, then on interval
    _checkAll();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkAll());
  }

  /// Stop polling (e.g. on sign-out).
  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _running = false;
    debugPrint('LimitWatcherService: stopped');
  }

  bool get isRunning => _running;

  // ── Main check ────────────────────────────────────────────────────────────

  Future<void> _checkAll() async {
    try {
      final hasPermission = await _usageService.hasPermission();
      if (!hasPermission) return;

      await Future.wait([
        _checkPerAppLimits(),
        _checkContinuousSession(),
        _checkTotalScreenTime(),
      ]);
    } catch (e) {
      debugPrint('LimitWatcherService: error during check — $e');
    }
  }

  // ── Check 1: Per-app daily limits ─────────────────────────────────────────

  Future<void> _checkPerAppLimits() async {
    final usage = await _usageService.getDailyUsage(); // pkg → minutes today

    for (final entry in usage.entries) {
      final pkg = entry.key;
      final usedMinutes = entry.value;
      final limitMinutes = _appLimits[pkg] ?? _defaultAppLimitMinutes;

      final pct = usedMinutes / limitMinutes;

      if (pct >= 1.0) {
        // Tier 3 — exceeded
        if (await _canNudge('limit_exceeded_$pkg')) {
          await _notificationService.showLimitExceeded(
              _friendlyName(pkg), usedMinutes);
          await _markNudged('limit_exceeded_$pkg');
        }
      } else if (pct >= 0.8) {
        // Tier 2 — 80%
        if (await _canNudge('limit_warn_moderate_$pkg')) {
          await _notificationService.showLimitWarningModerate(
              _friendlyName(pkg), usedMinutes, limitMinutes);
          await _markNudged('limit_warn_moderate_$pkg');
        }
      } else if (pct >= 0.5) {
        // Tier 1 — 50%
        if (await _canNudge('limit_warn_gentle_$pkg')) {
          await _notificationService.showLimitWarningGentle(
              _friendlyName(pkg), limitMinutes);
          await _markNudged('limit_warn_gentle_$pkg');
        }
      }
    }
  }

  // ── Check 2: Continuous single-app session ────────────────────────────────

  Future<void> _checkContinuousSession() async {
    final session = await _usageService.getCurrentContinuousSession();
    if (session == null) return;

    final durationMinutes = session.durationMs ~/ 60000;
    if (durationMinutes < _continuousSessionLimitMinutes) return;

    final key = 'continuous_${session.packageName}';
    if (await _canNudge(key, cooldown: _continuousNudgeCooldown)) {
      await _notificationService.showContinuousSessionNudge(
          _friendlyName(session.packageName), durationMinutes);
      await _markNudged(key);
    }
  }

  // ── Check 3: Total daily screen time ──────────────────────────────────────

  Future<void> _checkTotalScreenTime() async {
    final totalMinutes = await _usageService.getTotalUsageMinutes();

    // Nudge at 2h, 3h, 4h thresholds
    final thresholds = [_totalDailyLimitMinutes, 180, 240];

    for (final threshold in thresholds) {
      if (totalMinutes >= threshold) {
        final key = 'total_screen_${threshold}min';
        if (await _canNudge(key, cooldown: _totalScreenTimeCooldown)) {
          await _notificationService.showTotalScreenTimeNudge(totalMinutes);
          await _markNudged(key);
          break; // only fire one total-screen-time nudge per poll
        }
      }
    }
  }

  // ── Cooldown helpers ──────────────────────────────────────────────────────

  Future<bool> _canNudge(String key,
      {Duration cooldown = _perAppNudgeCooldown}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt('nudge_ts_$key') ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return (nowMs - lastMs) >= cooldown.inMilliseconds;
  }

  Future<void> _markNudged(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'nudge_ts_$key', DateTime.now().millisecondsSinceEpoch);
  }

  /// Clears all nudge cooldown timestamps — useful for testing.
  Future<void> resetAllCooldowns() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('nudge_ts_'));
    for (final k in keys) {
      await prefs.remove(k);
    }
    debugPrint('LimitWatcherService: all nudge cooldowns cleared');
  }

  // ── Package name → friendly display name ─────────────────────────────────

  static const Map<String, String> _friendlyNames = {
    'com.instagram.android': 'Instagram',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.facebook.katana': 'Facebook',
    'com.twitter.android': 'Twitter/X',
    'com.snapchat.android': 'Snapchat',
    'com.reddit.frontpage': 'Reddit',
    'com.youtube.android': 'YouTube',
    'com.google.android.youtube': 'YouTube',
    'com.whatsapp': 'WhatsApp',
    'com.google.android.gm': 'Gmail',
    'com.netflix.mediaclient': 'Netflix',
  };

  static String _friendlyName(String pkg) {
    if (_friendlyNames.containsKey(pkg)) return _friendlyNames[pkg]!;
    // Fallback: extract last segment of package name and capitalise
    final parts = pkg.split('.');
    final last = parts.last;
    return last[0].toUpperCase() + last.substring(1);
  }
}