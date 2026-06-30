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

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get totalSavedHours => _totalSavedHours;
  int get savedHours => _totalSavedHours;
  List<bool> get weekActivity => _weekActivity;

  StreakState() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('streak_current') ?? 0;
    _longestStreak = prefs.getInt('streak_longest') ?? 0;
    _totalSavedHours = prefs.getInt('streak_saved_hours') ?? 0;
    final dateStr = prefs.getString('streak_last_date');
    _lastActiveDate = dateStr != null ? DateTime.tryParse(dateStr) : null;

    final weekStr = prefs.getString('streak_week') ?? '0,0,0,0,0,0,0';
    final parts = weekStr.split(',');
    _weekActivity = List.generate(7, (i) => parts[i] == '1');

    _maybeResetWeek(prefs);
    _checkAndUpdate();
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
      _saveWeekStart(prefs, today);
    }
  }

  void _saveWeekStart(SharedPreferences prefs, DateTime date) {
    prefs.setString('streak_week_start', date.toIso8601String());
  }

  void _checkAndUpdate() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (_lastActiveDate == null) return;
    final lastDate = DateTime(
      _lastActiveDate!.year, _lastActiveDate!.month, _lastActiveDate!.day,
    );
    final diff = todayDate.difference(lastDate).inDays;
    if (diff > 1) {
      _currentStreak = 0;
      _save();
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

  Future<void> _save({bool skipRemoteSync = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak_current', _currentStreak);
    await prefs.setInt('streak_longest', _longestStreak);
    await prefs.setInt('streak_saved_hours', _totalSavedHours);
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