class UsagePermissionDeniedException implements Exception {
  final String message;
  UsagePermissionDeniedException([this.message = 'Usage permission not granted']);

  @override
  String toString() => 'UsagePermissionDeniedException: $message';
}

abstract class UsageService {
  Future<Map<String, int>> getDailyUsage();
  Future<int> getTotalUsageMinutes();
}

abstract class PermissionedUsageService implements UsageService {
  Future<bool> hasPermission();
  Future<void> requestPermission();
}
