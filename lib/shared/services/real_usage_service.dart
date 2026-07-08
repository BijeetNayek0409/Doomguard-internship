import 'package:usage_stats/usage_stats.dart';
import 'usage_service.dart';

/// Android event type constants (returned as Strings by the usage_stats package).
const String _eventForeground = '1'; // ACTIVITY_RESUMED / MOVE_TO_FOREGROUND
const String _eventBackground = '2'; // ACTIVITY_PAUSED  / MOVE_TO_BACKGROUND

/// Package names that are pure system/background processes that should NOT
/// count as user screen time.
const _systemPackages = {
  // ── This app ──────────────────────────────────────────────────────────────
  'com.example.doomguard', // exclude DoomGuard itself

  // ── Android system ────────────────────────────────────────────────────────
  'android',
  'android.process.media',
  'android.process.acore',
  'com.android.systemui',
  'com.android.phone',
  'com.android.bluetooth',
  'com.android.nfc',
  'com.android.server.telecom',
  'com.android.settings',
  'com.android.externalstorage',
  'com.android.providers.media',
  'com.android.providers.downloads',
  'com.android.providers.contacts',
  'com.android.providers.calendar',
  'com.android.providers.settings',
  'com.android.providers.telephony',
  'com.android.inputmethod.latin',
  'com.android.keyguard',
  'com.android.shell',
  'com.android.vending',
  'com.android.defcontainer',
  'com.android.packageinstaller',
  'com.google.android.gms',
  'com.google.android.gsf',
  'com.google.process.gapps',
  'com.google.android.partnersetup',
  'com.google.android.onetimeinitializer',
  'com.samsung.android.incallui',
  'com.samsung.android.networkstack',
  'com.sec.android.daemonapp',
  'com.android.captiveportallogin',
};

/// Info about whichever app has been continuously in the foreground,
/// without switching away, up to the moment this was queried.
class ContinuousSession {
  final String packageName;
  final int startMs;
  final int durationMs;

  const ContinuousSession({
    required this.packageName,
    required this.startMs,
    required this.durationMs,
  });
}

class RealUsageService implements PermissionedUsageService {
  @override
  Future<bool> hasPermission() async {
    final granted = await UsageStats.checkUsagePermission();
    return granted ?? false;
  }

  @override
  Future<void> requestPermission() async {
    await UsageStats.grantUsagePermission();
  }

  @override
  Future<Map<String, int>> getDailyUsage() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return getUsageForRange(startOfDay, now);
  }

  @override
  Future<int> getTotalUsageMinutes() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return getTotalUsageMinutesForRange(startOfDay, now);
  }

  @override
  Future<Map<String, int>> getUsageForRange(DateTime start, DateTime end) async {
    final granted = await hasPermission();
    if (!granted) {
      throw UsagePermissionDeniedException(
          'Usage access permission required. Please grant it in settings.');
    }

    // Try event-based calculation first (most accurate)
    final rawMs = await _computeForegroundMsFromEvents(start, end);

    // If events returned nothing meaningful, fall back to aggregate API.
    // This can happen on some devices/Android versions that don't emit events
    // for all packages.
    final Map<String, int> rawMsToUse;
    if (rawMs.isEmpty) {
      rawMsToUse = await _computeForegroundMsFromAggregate(start, end);
    } else {
      rawMsToUse = rawMs;
    }

    // Convert ms → minutes (floor division), keep only ≥1 full minute
    final result = <String, int>{};
    for (final entry in rawMsToUse.entries) {
      final minutes = entry.value ~/ 60000;
      if (minutes >= 1) {
        result[entry.key] = minutes;
      }
    }
    return result;
  }

  @override
  Future<int> getTotalUsageMinutesForRange(DateTime start, DateTime end) async {
    final granted = await hasPermission();
    if (!granted) return 0;

    // Sum raw ms first, then convert ONCE (avoids per-app rounding errors)
    var rawMs = await _computeForegroundMsFromEvents(start, end);
    if (rawMs.isEmpty) {
      rawMs = await _computeForegroundMsFromAggregate(start, end);
    }
    final totalMs = rawMs.values.fold<int>(0, (s, ms) => s + ms);
    return totalMs ~/ 60000;
  }

  /// Returns whichever app is currently open and has been continuously
  /// in the foreground without interruption — or null if nothing
  /// qualifies (e.g. permission missing, or the last known event was a
  /// background/close event). Used to detect long single-app sessions
  /// (e.g. 45+ minutes scrolling one app without switching away).
  Future<ContinuousSession?> getCurrentContinuousSession() async {
    final granted = await hasPermission();
    if (!granted) return null;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final events = await UsageStats.queryEvents(startOfDay, now);

    // Track the most recent unmatched FOREGROUND event per package —
    // same walking approach as _computeForegroundMsFromEvents, but here
    // we only care about whatever's still "open" at the very end.
    final Map<String, int> foregroundStart = {};

    for (final event in events) {
      final pkg = event.packageName ?? '';
      if (pkg.isEmpty || _isSystemPackage(pkg)) continue;

      final type = event.eventType ?? '';
      final ts = int.tryParse(event.timeStamp ?? '0') ?? 0;

      if (type == _eventForeground) {
        foregroundStart[pkg] = ts;
      } else if (type == _eventBackground) {
        foregroundStart.remove(pkg);
      }
    }

    if (foregroundStart.isEmpty) return null;

    // Only one app can genuinely be foreground at a time on Android, but
    // guard against edge cases by picking the most recently started one.
    final entry = foregroundStart.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
    );

    final nowMs = now.millisecondsSinceEpoch;
    return ContinuousSession(
      packageName: entry.key,
      startMs: entry.value,
      durationMs: nowMs - entry.value,
    );
  }

  // ── Method 1: event-based (precise, handles window boundary) ────────────────

  Future<Map<String, int>> _computeForegroundMsFromEvents(
      DateTime start, DateTime end) async {
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    final events = await UsageStats.queryEvents(start, end);

    // Map: packageName -> timestamp(ms) of last FOREGROUND event
    final Map<String, int> foregroundStart = {};
    // Map: packageName -> accumulated foreground ms
    final Map<String, int> accumulated = {};

    for (final event in events) {
      final pkg = event.packageName ?? '';
      if (pkg.isEmpty || _isSystemPackage(pkg)) continue;

      // eventType is a String in usage_stats 1.3.1
      final type = event.eventType ?? '';
      final ts = int.tryParse(event.timeStamp ?? '0') ?? 0;

      if (type == _eventForeground) {
        // Clamp to window start so sessions that began before the window
        // don't bleed in extra time
        foregroundStart[pkg] = ts < startMs ? startMs : ts;
      } else if (type == _eventBackground) {
        final fgStart = foregroundStart.remove(pkg);
        if (fgStart != null && ts > fgStart) {
          accumulated[pkg] = (accumulated[pkg] ?? 0) + (ts - fgStart);
        }
      }
    }

    // Apps still in foreground at the end of the window: count up to endMs
    for (final entry in foregroundStart.entries) {
      if (endMs > entry.value) {
        accumulated[entry.key] =
            (accumulated[entry.key] ?? 0) + (endMs - entry.value);
      }
    }

    return accumulated;
  }

  // ── Method 2: aggregate API fallback ──────────────────────────────────────

  Future<Map<String, int>> _computeForegroundMsFromAggregate(
      DateTime start, DateTime end) async {
    final Map<String, int> rawMs = {};

    final aggregated = await UsageStats.queryAndAggregateUsageStats(start, end);
    for (final entry in aggregated.entries) {
      final pkg = entry.key;
      if (_isSystemPackage(pkg)) continue;

      final ms = _parseMs(entry.value.totalTimeInForeground);
      if (ms > 0) rawMs[pkg] = (rawMs[pkg] ?? 0) + ms;
    }

    // If aggregate is also empty, try raw queryUsageStats
    if (rawMs.isEmpty) {
      final stats = await UsageStats.queryUsageStats(start, end);
      for (final info in stats) {
        final pkg = info.packageName ?? '';
        if (pkg.isEmpty || _isSystemPackage(pkg)) continue;
        final ms = _parseMs(info.totalTimeInForeground);
        if (ms > 0) rawMs[pkg] = (rawMs[pkg] ?? 0) + ms;
      }
    }

    return rawMs;
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  static int _parseMs(String? value) {
    if (value == null || value.isEmpty) return 0;
    return int.tryParse(value) ?? 0;
  }

  static bool _isSystemPackage(String pkg) {
    if (_systemPackages.contains(pkg)) return true;
    // Heuristic: com.android.* packages that aren't user-visible apps
    if (pkg.startsWith('com.android.') &&
        !pkg.contains('chrome') &&
        !pkg.contains('camera') &&
        !pkg.contains('gallery') &&
        !pkg.contains('dialer') &&
        !pkg.contains('contacts') &&
        !pkg.contains('messaging') &&
        !pkg.contains('mms') &&
        !pkg.contains('calculator')) {
      return true;
    }
    return false;
  }
}