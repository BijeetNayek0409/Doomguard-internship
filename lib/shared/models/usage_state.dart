import 'package:flutter/foundation.dart';
import '../services/usage_service.dart';

class UsageState extends ChangeNotifier {
  final UsageService usageService;

  UsageState({required this.usageService});

  Map<String, int> _dailyUsage = {};
  int? _totalUsageMinutes;
  bool _loading = false;
  bool _permissionGranted = true;
  String? _error;

  Map<String, int> get dailyUsage => _dailyUsage;
  int get totalUsageMinutes => _totalUsageMinutes ?? 0;
  bool get loading => _loading;
  bool get permissionGranted => _permissionGranted;
  String? get error => _error;

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

  Future<void> requestPermission() async {
    if (usageService is PermissionedUsageService) {
      await (usageService as PermissionedUsageService).requestPermission();
      await loadUsage();
    }
  }
}

