class UsagePermissionDeniedException implements Exception {
  final String message;
  UsagePermissionDeniedException([this.message = 'Usage permission not granted']);

  @override
  String toString() => 'UsagePermissionDeniedException: $message';
}

abstract class UsageService {
  Future<Map<String, int>> getDailyUsage();
  Future<int> getTotalUsageMinutes();

  /// Per-app usage minutes for an arbitrary [start, end] window.
  Future<Map<String, int>> getUsageForRange(DateTime start, DateTime end);

  /// Total usage minutes for an arbitrary [start, end] window.
  Future<int> getTotalUsageMinutesForRange(DateTime start, DateTime end);
}

abstract class PermissionedUsageService implements UsageService {
  Future<bool> hasPermission();
  Future<void> requestPermission();
}