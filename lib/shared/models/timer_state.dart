import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_stats_service.dart'; // adjust path if your tree differs

enum TimerMode { focus, shortBreak, longBreak }

class TimerState extends ChangeNotifier {
  static const int _focusMinutes = 25;
  static const int _shortBreakMinutes = 5;
  static const int _longBreakMinutes = 15;

  final _statsService = UserStatsService();
  String? _uid;
  bool _hydrated = false;

  TimerMode _mode = TimerMode.focus;
  int _secondsLeft = _focusMinutes * 60;
  bool _running = false;
  int _completedSessions = 0;
  int _totalFocusMinutesToday = 0;

  Timer? _timer;

  TimerMode get mode => _mode;
  int get secondsLeft => _secondsLeft;
  bool get running => _running;
  int get completedSessions => _completedSessions;
  int get totalFocusMinutesToday => _totalFocusMinutesToday;

  bool get isRunning => _running;
  bool get isBreak => _mode != TimerMode.focus;
  int get sessionsToday => _completedSessions;
  int get focusMinutesToday => _totalFocusMinutesToday;

  String get formattedTime {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get totalSeconds {
    switch (_mode) {
      case TimerMode.focus:
        return _focusMinutes * 60;
      case TimerMode.shortBreak:
        return _shortBreakMinutes * 60;
      case TimerMode.longBreak:
        return _longBreakMinutes * 60;
    }
  }

  double get progress => 1.0 - (_secondsLeft / totalSeconds);

  TimerState() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('timer_date') ?? '';
    if (savedDate == today) {
      _completedSessions = prefs.getInt('timer_sessions') ?? 0;
      _totalFocusMinutesToday = prefs.getInt('timer_focus_minutes') ?? 0;
    } else {
      _completedSessions = 0;
      _totalFocusMinutesToday = 0;
      await prefs.setString('timer_date', today);
      await prefs.setInt('timer_sessions', 0);
      await prefs.setInt('timer_focus_minutes', 0);
    }
    notifyListeners();
  }

  /// Call after login. Hydrates today's session/focus-minute counts from
  /// Firestore on a fresh install — only if local is at zero (new device),
  /// since "today" counts should otherwise stay device-local once active.
  Future<void> setUid(String? uid) async {
    _uid = uid;
    if (uid == null || _hydrated) return;
    _hydrated = true;

    try {
      final remote = await _statsService.fetchStats(uid);
      final remoteSessions = remote['sessionsToday'] as int;
      final remoteFocusMinutes = remote['focusMinutesToday'] as int;

      // Only adopt remote "today" values if local has nothing yet — this is
      // the fresh-install/new-device case. If local already has activity
      // today, trust the device that's actually being used right now.
      if (_completedSessions == 0 && _totalFocusMinutesToday == 0) {
        if (remoteSessions > 0 || remoteFocusMinutes > 0) {
          _completedSessions = remoteSessions;
          _totalFocusMinutesToday = remoteFocusMinutes;
          await _saveData(skipRemoteSync: true);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('TimerState: failed to hydrate from Firestore: $e');
    }
  }

  Future<void> _saveData({bool skipRemoteSync = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString('timer_date', today);
    await prefs.setInt('timer_sessions', _completedSessions);
    await prefs.setInt('timer_focus_minutes', _totalFocusMinutesToday);

    if (!skipRemoteSync && _uid != null) {
      unawaited(_statsService.syncTimerStats(
        _uid!,
        sessionsToday: _completedSessions,
        focusMinutesToday: _totalFocusMinutesToday,
      ));
    }
  }

  void setMode(TimerMode m) {
    _timer?.cancel();
    _running = false;
    _mode = m;
    _secondsLeft = totalSeconds;
    notifyListeners();
  }

  void startStop() {
    if (_running) {
      _timer?.cancel();
      _running = false;
    } else {
      _running = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
    notifyListeners();
  }

  void startTimer() {
    if (!_running) startStop();
  }

  void pauseTimer() {
    if (_running) startStop();
  }

  void resetTimer() => reset();

  void reset() {
    _timer?.cancel();
    _running = false;
    _secondsLeft = totalSeconds;
    notifyListeners();
  }

  void setDuration(int minutes) {
    _timer?.cancel();
    _running = false;
    _secondsLeft = minutes * 60;
    notifyListeners();
  }

  void _tick() {
    if (_secondsLeft > 0) {
      _secondsLeft--;
      notifyListeners();
    } else {
      _timer?.cancel();
      _running = false;
      _onComplete();
    }
  }

  void _onComplete() {
    if (_mode == TimerMode.focus) {
      _completedSessions++;
      _totalFocusMinutesToday += _focusMinutes;
      _saveData();
      if (_completedSessions % 4 == 0) {
        setMode(TimerMode.longBreak);
      } else {
        setMode(TimerMode.shortBreak);
      }
    } else {
      setMode(TimerMode.focus);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}