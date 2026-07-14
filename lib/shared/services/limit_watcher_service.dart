import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'real_usage_service.dart';
import 'notification_service.dart';

// ── Default per-app daily limits (minutes) ────────────────────────────────────
const Map<String, int> _appLimits = {
  'com.instagram.android': 30,
  'com.facebook.katana': 30,
  'com.twitter.android': 30,
  'com.snapchat.android': 30,
  'com.reddit.frontpage': 45,
  'com.youtube.android': 25,
  'com.google.android.youtube': 25,
};

const int _defaultAppLimitMinutes = 60;
const int _continuousSessionLimitMinutes = 30;

// Nudge cooldowns
const Duration _perAppCooldown = Duration(minutes: 15);
const Duration _continuousCooldown = Duration(minutes: 10);
const Duration _totalScreenTimeCooldown = Duration(minutes: 30);

const Duration _pollInterval = Duration(minutes: 1);

class LimitWatcherService {
  static final LimitWatcherService _instance = LimitWatcherService._internal();
  factory LimitWatcherService() => _instance;
  LimitWatcherService._internal();

  final _usageService = RealUsageService();
  final _notificationService = NotificationService();

  Timer? _pollTimer;
  bool _running = false;

  // Live settings values — updated by setSettings() from _StatsSyncBootstrapper
  bool _notificationsEnabled = true;
  bool _strictMode = false;
  int _dailyLimitMinutes = 120;
  int _downtimeStart = 22;
  int _downtimeEnd = 7;

  // Strict mode callback — set by whoever manages the overlay (main.dart)
  VoidCallback? onStrictModeBlock;

  bool get isRunning => _running;
  bool get strictMode => _strictMode;

  /// Push latest settings values into the watcher each time they change.
  void setSettings({
    required bool notificationsEnabled,
    required bool strictMode,
    required int dailyLimitMinutes,
    required int downtimeStart,
    required int downtimeEnd,
  }) {
    _notificationsEnabled = notificationsEnabled;
    _strictMode = strictMode;
    _dailyLimitMinutes = dailyLimitMinutes;
    _downtimeStart = downtimeStart;
    _downtimeEnd = downtimeEnd;
  }

  void start() {
    if (_running) return;
    _running = true;
    debugPrint('LimitWatcherService: started');
    _checkAll();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkAll());
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _running = false;
    debugPrint('LimitWatcherService: stopped');
  }

  // ── Main check ─────────────────────────────────────────────────────────────

  Future<void> _checkAll() async {
    try {
      final hasPermission = await _usageService.hasPermission();
      if (!hasPermission) return;

      // Strict mode: check downtime window first
      if (_strictMode) {
        await _checkDowntime();
      }

      // Nudges: only fire if notifications are enabled
      if (_notificationsEnabled) {
        await Future.wait([
          _checkPerAppLimits(),
          _checkContinuousSession(),
          _checkTotalScreenTime(),
        ]);
      }
    } catch (e) {
      debugPrint('LimitWatcherService: error — $e');
    }
  }

  // ── Strict mode: downtime enforcement ──────────────────────────────────────

  Future<void> _checkDowntime() async {
    final now = DateTime.now();
    final hour = now.hour;
    final inDowntime = _downtimeStart <= _downtimeEnd
        ? hour >= _downtimeStart && hour < _downtimeEnd
        : hour >= _downtimeStart || hour < _downtimeEnd; // crosses midnight

    if (inDowntime && onStrictModeBlock != null) {
      onStrictModeBlock!();
    }
  }

  // ── Check 1: per-app daily limits ──────────────────────────────────────────

  Future<void> _checkPerAppLimits() async {
    final usage = await _usageService.getDailyUsage();

    for (final entry in usage.entries) {
      final pkg = entry.key;
      final usedMinutes = entry.value;
      final limitMinutes = _appLimits[pkg] ?? _defaultAppLimitMinutes;
      final pct = usedMinutes / limitMinutes;

      if (pct >= 1.0) {
        if (await _canNudge('limit_exceeded_$pkg')) {
          await _notificationService.showLimitExceeded(
              _friendlyName(pkg), usedMinutes);
          await _markNudged('limit_exceeded_$pkg');
        }
      } else if (pct >= 0.8) {
        if (await _canNudge('limit_warn_moderate_$pkg')) {
          await _notificationService.showLimitWarningModerate(
              _friendlyName(pkg), usedMinutes, limitMinutes);
          await _markNudged('limit_warn_moderate_$pkg');
        }
      } else if (pct >= 0.5) {
        if (await _canNudge('limit_warn_gentle_$pkg')) {
          await _notificationService.showLimitWarningGentle(
              _friendlyName(pkg), limitMinutes);
          await _markNudged('limit_warn_gentle_$pkg');
        }
      }
    }
  }

  // ── Check 2: continuous single-app session ──────────────────────────────────

  Future<void> _checkContinuousSession() async {
    final session = await _usageService.getCurrentContinuousSession();
    if (session == null) return;

    final durationMinutes = session.durationMs ~/ 60000;
    if (durationMinutes < _continuousSessionLimitMinutes) return;

    final key = 'continuous_${session.packageName}';
    if (await _canNudge(key, cooldown: _continuousCooldown)) {
      await _notificationService.showContinuousSessionNudge(
          _friendlyName(session.packageName), durationMinutes);
      await _markNudged(key);
    }
  }

  // ── Check 3: total daily screen time ───────────────────────────────────────

  Future<void> _checkTotalScreenTime() async {
    final totalMinutes = await _usageService.getTotalUsageMinutes();

    // Nudge at user's daily limit, then 3h, 4h
    final thresholds = [_dailyLimitMinutes, 180, 240];

    for (final threshold in thresholds) {
      if (totalMinutes >= threshold) {
        final key = 'total_screen_${threshold}min';
        if (await _canNudge(key, cooldown: _totalScreenTimeCooldown)) {
          await _notificationService.showTotalScreenTimeNudge(totalMinutes);
          await _markNudged(key);
          break;
        }
      }
    }
  }

  // ── Cooldown helpers ───────────────────────────────────────────────────────

  Future<bool> _canNudge(String key,
      {Duration cooldown = _perAppCooldown}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt('nudge_ts_$key') ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return (nowMs - lastMs) >= cooldown.inMilliseconds;
  }

  Future<void> _markNudged(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nudge_ts_$key', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> resetAllCooldowns() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('nudge_ts_'));
    for (final k in keys) await prefs.remove(k);
    debugPrint('LimitWatcherService: all nudge cooldowns cleared');
  }

  // ── Package → friendly name ────────────────────────────────────────────────

  static const Map<String, String> _friendlyNames = {
    'com.instagram.android': 'Instagram',
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
    final parts = pkg.split('.');
    final last = parts.last;
    return last[0].toUpperCase() + last.substring(1);
  }
}