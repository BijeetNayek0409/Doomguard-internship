import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_stats_service.dart';

class StreakState extends ChangeNotifier {
  final _statsService = UserStatsService();
  String? _uid;
  bool _hydrated = false;

  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalSavedHours = 0;
  DateTime? _lastActiveDate;
  List<bool> _weekActivity = List.filled(7, false);

  bool _streakFreezeAvailable = true;
  bool _streakFrozenThisPeriod = false; // true if freeze was just auto-applied

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get totalSavedHours => _totalSavedHours;
  int get savedHours => _totalSavedHours;
  List<bool> get weekActivity => _weekActivity;
  bool get isStreakFreezeAvailable => _streakFreezeAvailable;
  bool get streakFrozenThisPeriod => _streakFrozenThisPeriod;

  StreakState() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('streak_current') ?? 0;
    _longestStreak = prefs.getInt('streak_longest') ?? 0;
    _totalSavedHours = prefs.getInt('streak_saved_hours') ?? 0;
    _streakFreezeAvailable = prefs.getBool('streak_freeze_available') ?? true;
    final dateStr = prefs.getString('streak_last_date');
    _lastActiveDate = dateStr != null ? DateTime.tryParse(dateStr) : null;

    final weekStr = prefs.getString('streak_week') ?? '0,0,0,0,0,0,0';
    final parts = weekStr.split(',');
    _weekActivity = List.generate(7, (i) => parts[i] == '1');

    _maybeResetWeek(prefs);
    await _checkAndUpdate();
    notifyListeners();
  }

  void _maybeResetWeek(SharedPreferences prefs) {
    final today = DateTime.now();
    final weekKeyStr = prefs.getString('streak_week_start');
    if (weekKeyStr == null) {
      _saveWeekStart(prefs, today);
      return;
    }
    final weekStart = DateTime.tryParse(weekKeyStr);
    if (weekStart == null) return;
    final diff = today.difference(weekStart).inDays;
    if (diff >= 7) {
      _weekActivity = List.filled(7, false);
      _streakFreezeAvailable = true; // freeze allowance renews weekly too
      prefs.setBool('streak_freeze_available', true);
      _saveWeekStart(prefs, today);
    }
  }

  void _saveWeekStart(SharedPreferences prefs, DateTime date) {
    prefs.setString('streak_week_start', date.toIso8601String());
  }

  Future<void> _checkAndUpdate() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (_lastActiveDate == null) return;
    final lastDate = DateTime(
      _lastActiveDate!.year, _lastActiveDate!.month, _lastActiveDate!.day,
    );
    final diff = todayDate.difference(lastDate).inDays;

    if (diff == 2 && _streakFreezeAvailable) {
      // Exactly one day was missed — cover it with the freeze instead of
      // resetting the streak.
      _streakFreezeAvailable = false;
      _streakFrozenThisPeriod = true;
      if (_uid != null) {
        unawaited(_statsService.useStreakFreeze(_uid!));
      }
      await _save();
    } else if (diff > 1) {
      // Either more than one day was missed, or no freeze was available.
      _currentStreak = 0;
      await _save();
    }
  }

  Future<void> setUid(String? uid) async {
    _uid = uid;
    if (uid == null || _hydrated) return;
    _hydrated = true;

    try {
      final remote = await _statsService.fetchStats(uid);
      final remoteCurrent = remote['currentStreak'] as int;
      final remoteLongest = remote['longestStreak'] as int;
      final remoteSaved = remote['totalSavedHours'] as int;
      final remoteFreeze = remote['streakFreezeAvailable'] as bool?;

      bool changed = false;
      if (remoteCurrent > _currentStreak) {
        _currentStreak = remoteCurrent;
        changed = true;
      }
      if (remoteLongest > _longestStreak) {
        _longestStreak = remoteLongest;
        changed = true;
      }
      if (remoteSaved > _totalSavedHours) {
        _totalSavedHours = remoteSaved;
        changed = true;
      }
      // Server already applies the weekly reset (see _resolveStreakFreeze
      // in UserStatsService), so it's authoritative here rather than
      // "take the higher value" like the other stats.
      if (remoteFreeze != null && remoteFreeze != _streakFreezeAvailable) {
        _streakFreezeAvailable = remoteFreeze;
        changed = true;
      }

      if (changed) {
        await _save(skipRemoteSync: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('StreakState: failed to hydrate from Firestore: $e');
    }
  }

  Future<void> markDayActive({int savedMinutes = 0}) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final weekdayIndex = today.weekday - 1;
    _weekActivity[weekdayIndex] = true;
    _streakFrozenThisPeriod = false; // clear the "was frozen" flag once active again

    if (_lastActiveDate != null) {
      final lastDate = DateTime(
        _lastActiveDate!.year, _lastActiveDate!.month, _lastActiveDate!.day,
      );
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 0) {
        _totalSavedHours += (savedMinutes ~/ 60);
        await _save();
        notifyListeners();
        return;
      } else if (diff == 1) {
        _currentStreak++;
      } else if (diff == 2 && _streakFreezeAvailable) {
        // They missed yesterday but a freeze is still available — cover it
        // and continue the streak instead of restarting at 1.
        _streakFreezeAvailable = false;
        if (_uid != null) {
          unawaited(_statsService.useStreakFreeze(_uid!));
        }
        _currentStreak++;
      } else {
        _currentStreak = 1;
      }
    } else {
      _currentStreak = 1;
    }

    if (_currentStreak > _longestStreak) _longestStreak = _currentStreak;
    _totalSavedHours += (savedMinutes ~/ 60);
    _lastActiveDate = todayDate;
    await _save();
    notifyListeners();
  }

  /// Call this after showing the "your streak was frozen" banner once,
  /// if you want it to disappear immediately rather than waiting for the
  /// next active day.
  void dismissFreezeBanner() {
    if (!_streakFrozenThisPeriod) return;
    _streakFrozenThisPeriod = false;
    notifyListeners();
  }

  Future<void> _save({bool skipRemoteSync = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak_current', _currentStreak);
    await prefs.setInt('streak_longest', _longestStreak);
    await prefs.setInt('streak_saved_hours', _totalSavedHours);
    await prefs.setBool('streak_freeze_available', _streakFreezeAvailable);
    if (_lastActiveDate != null) {
      await prefs.setString('streak_last_date', _lastActiveDate!.toIso8601String());
    }
    final weekStr = _weekActivity.map((b) => b ? '1' : '0').join(',');
    await prefs.setString('streak_week', weekStr);

    if (!skipRemoteSync && _uid != null) {
      unawaited(_statsService.syncStreakStats(
        _uid!,
        currentStreak: _currentStreak,
        longestStreak: _longestStreak,
        totalSavedHours: _totalSavedHours,
      ));
    }
  }
}