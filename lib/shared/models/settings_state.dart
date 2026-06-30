import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends ChangeNotifier {
  bool _dailyLimitEnforced = true;
  bool _strictMode = false;
  bool _showWarnings = true;
  bool _weeklyReports = true;
  int _dailyLimitMinutes = 120; // default 2 hours
  int _downtimeStartHour = 22; // 10 PM
  int _downtimeEndHour = 7;   // 7 AM

  bool get dailyLimitEnforced => _dailyLimitEnforced;
  bool get strictMode => _strictMode;
  bool get showWarnings => _showWarnings;
  bool get weeklyReports => _weeklyReports;
  int get dailyLimitMinutes => _dailyLimitMinutes;
  int get downtimeStartHour => _downtimeStartHour;
  int get downtimeEndHour => _downtimeEndHour;

  // Convenience aliases for UI
  int get downtimeStart => _downtimeStartHour;
  int get downtimeEnd => _downtimeEndHour;
  bool get notificationsEnabled => _showWarnings;
  void setNotifications(bool v) => setShowWarnings(v);
  void setDailyLimit(int v) => setDailyLimitMinutes(v);
  void setDowntime(int start, int end) {
    setDowntimeStartHour(start);
    setDowntimeEndHour(end);
  }

  SettingsState() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyLimitEnforced = prefs.getBool('settings_limit_enforced') ?? true;
    _strictMode = prefs.getBool('settings_strict_mode') ?? false;
    _showWarnings = prefs.getBool('settings_show_warnings') ?? true;
    _weeklyReports = prefs.getBool('settings_weekly_reports') ?? true;
    _dailyLimitMinutes = prefs.getInt('settings_daily_limit_min') ?? 120;
    _downtimeStartHour = prefs.getInt('settings_downtime_start') ?? 22;
    _downtimeEndHour = prefs.getInt('settings_downtime_end') ?? 7;
    notifyListeners();
  }

  Future<void> setDailyLimitEnforced(bool v) async {
    _dailyLimitEnforced = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_limit_enforced', v);
  }

  Future<void> setStrictMode(bool v) async {
    _strictMode = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_strict_mode', v);
  }

  Future<void> setShowWarnings(bool v) async {
    _showWarnings = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_show_warnings', v);
  }

  Future<void> setWeeklyReports(bool v) async {
    _weeklyReports = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_weekly_reports', v);
  }

  Future<void> setDailyLimitMinutes(int v) async {
    _dailyLimitMinutes = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('settings_daily_limit_min', v);
  }

  Future<void> setDowntimeStartHour(int h) async {
    _downtimeStartHour = h;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('settings_downtime_start', h);
  }

  Future<void> setDowntimeEndHour(int h) async {
    _downtimeEndHour = h;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('settings_downtime_end', h);
  }

  String get downtimeLabel {
    String fmt(int h) => h == 0
        ? '12 AM'
        : h < 12
            ? '${h} AM'
            : h == 12
                ? '12 PM'
                : '${h - 12} PM';
    return '${fmt(_downtimeStartHour)} – ${fmt(_downtimeEndHour)}';
  }
}
