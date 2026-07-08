import 'usage_service.dart';

class MockUsageService implements UsageService {
  static const Map<String, int> _baseDailyMinutes = {
    'Instagram': 54,
    'YouTube': 41,
    'Twitter': 28,
    'Reddit': 18,
  };

  /// Returns mocked application usage data in minutes
  @override
  Future<Map<String, int>> getDailyUsage() async {
    // Simulate slight delay for realistic async testing
    await Future.delayed(const Duration(milliseconds: 500));
    return Map<String, int>.from(_baseDailyMinutes);
  }

  /// Calculates total usage minutes from the daily stats
  @override
  Future<int> getTotalUsageMinutes() async {
    final usages = await getDailyUsage();
    return usages.values.fold<int>(0, (int sum, int minutes) => sum + minutes);
  }

  /// Returns total total usage across the whole day explicitly
  Future<int> getTotalDailyMinutes() async {
    return await getTotalUsageMinutes();
  }

  /// Gets mocked weekly data (7 doubles) representing hours or relative usage.
  Future<List<double>> getWeeklyData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // E.g. usage across 7 days: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
    return [3.5, 4.2, 2.8, 5.1, 4.0, 6.5, 5.8];
  }

  /// Mocked per-app usage for an arbitrary range. Scales the base daily
  /// numbers by the number of days in the window, with a small per-app
  /// wobble so week/month don't look like a flat multiple of "today".
  @override
  Future<Map<String, int>> getUsageForRange(DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final days = end.difference(start).inDays + 1;
    final result = <String, int>{};
    var i = 0;
    for (final entry in _baseDailyMinutes.entries) {
      // Deterministic wobble per app so results are stable across rebuilds
      final wobble = 0.85 + (i % 4) * 0.1; // 0.85 - 1.15
      result[entry.key] = (entry.value * days * wobble).round();
      i++;
    }
    return result;
  }

  /// Mocked total usage minutes for an arbitrary range.
  @override
  Future<int> getTotalUsageMinutesForRange(DateTime start, DateTime end) async {
    final usages = await getUsageForRange(start, end);
    return usages.values.fold<int>(0, (int sum, int minutes) => sum + minutes);
  }
}