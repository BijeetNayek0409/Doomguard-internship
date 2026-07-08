import 'package:flutter/foundation.dart';
import '../services/usage_service.dart';

enum UsagePeriod { day, week, month }

class UsageState extends ChangeNotifier {
  final UsageService usageService;

  UsageState({required this.usageService});

  UsagePeriod _selectedPeriod = UsagePeriod.day;

  Map<String, int> _dailyUsage = {};
  Map<String, int> _weeklyUsage = {};
  Map<String, int> _monthlyUsage = {};

  int? _totalUsageMinutes;
  int? _weeklyTotalMinutes;
  int? _monthlyTotalMinutes;

  bool _loading = false;
  bool _loadingPeriod = false;
  bool _permissionGranted = true;
  String? _error;

  UsagePeriod get selectedPeriod => _selectedPeriod;

  Map<String, int> get dailyUsage => _dailyUsage;
  Map<String, int> get weeklyUsage => _weeklyUsage;
  Map<String, int> get monthlyUsage => _monthlyUsage;

  /// Per-app usage for whichever period is currently selected.
  /// UI widgets should read this instead of [dailyUsage] directly.
  Map<String, int> get currentUsage {
    switch (_selectedPeriod) {
      case UsagePeriod.day:
        return _dailyUsage;
      case UsagePeriod.week:
        return _weeklyUsage;
      case UsagePeriod.month:
        return _monthlyUsage;
    }
  }

  /// Total usage minutes for whichever period is currently selected.
  int get currentTotalMinutes {
    switch (_selectedPeriod) {
      case UsagePeriod.day:
        return _totalUsageMinutes ?? 0;
      case UsagePeriod.week:
        return _weeklyTotalMinutes ?? 0;
      case UsagePeriod.month:
        return _monthlyTotalMinutes ?? 0;
    }
  }

  int get totalUsageMinutes => _totalUsageMinutes ?? 0;
  bool get loading => _loading;
  bool get loadingPeriod => _loadingPeriod;
  bool get permissionGranted => _permissionGranted;
  String? get error => _error;

  /// Loads "today" data. Call this on app start / pull-to-refresh, same as before.
  Future<void> loadUsage() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _dailyUsage = await usageService.getDailyUsage();
      _totalUsageMinutes = await usageService.getTotalUsageMinutes();
      _permissionGranted = true;
    } on UsagePermissionDeniedException catch (e) {
      _permissionGranted = false;
      _error = e.message;
      _dailyUsage = {};
      _totalUsageMinutes = 0;
    } catch (e) {
      _error = 'Failed to load usage data';
      _dailyUsage = {};
      _totalUsageMinutes = 0;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Switches the active period (Day/Week/Month) and lazily loads its data
  /// the first time it's selected. Call this from the Stats screen's tab
  /// tap handler instead of just calling setState locally.
  Future<void> setPeriod(UsagePeriod period) async {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners(); // reflect the tab switch immediately

    final alreadyLoaded = (period == UsagePeriod.week && _weeklyTotalMinutes != null) ||
        (period == UsagePeriod.month && _monthlyTotalMinutes != null);
    if (period == UsagePeriod.day || alreadyLoaded) return;

    await _loadPeriodData(period);
  }

  /// Forces a reload of the currently selected period (e.g. pull-to-refresh).
  Future<void> refreshCurrentPeriod() async {
    if (_selectedPeriod == UsagePeriod.day) {
      await loadUsage();
    } else {
      await _loadPeriodData(_selectedPeriod);
    }
  }

  Future<void> _loadPeriodData(UsagePeriod period) async {
    _loadingPeriod = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final DateTime start;
      if (period == UsagePeriod.week) {
        // Last 7 days inclusive of today.
        final today = DateTime(now.year, now.month, now.day);
        start = today.subtract(const Duration(days: 6));
      } else {
        start = DateTime(now.year, now.month, 1);
      }

      final usage = await usageService.getUsageForRange(start, now);
      final total = await usageService.getTotalUsageMinutesForRange(start, now);

      if (period == UsagePeriod.week) {
        _weeklyUsage = usage;
        _weeklyTotalMinutes = total;
      } else {
        _monthlyUsage = usage;
        _monthlyTotalMinutes = total;
      }
      _permissionGranted = true;
    } on UsagePermissionDeniedException catch (e) {
      _permissionGranted = false;
      _error = e.message;
      if (period == UsagePeriod.week) {
        _weeklyUsage = {};
        _weeklyTotalMinutes = 0;
      } else {
        _monthlyUsage = {};
        _monthlyTotalMinutes = 0;
      }
    } catch (e) {
      _error = 'Failed to load usage data';
      if (period == UsagePeriod.week) {
        _weeklyUsage = {};
        _weeklyTotalMinutes = 0;
      } else {
        _monthlyUsage = {};
        _monthlyTotalMinutes = 0;
      }
    } finally {
      _loadingPeriod = false;
      notifyListeners();
    }
  }

  Future<void> requestPermission() async {
    if (usageService is PermissionedUsageService) {
      await (usageService as PermissionedUsageService).requestPermission();
      await loadUsage();
    }
  }
}