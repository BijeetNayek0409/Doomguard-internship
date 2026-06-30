import 'usage_service.dart';

class MockUsageService implements UsageService {
  /// Returns mocked application usage data in minutes
  @override
  Future<Map<String, int>> getDailyUsage() async {
    // Simulate slight delay for realistic async testing
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'Instagram': 54,
      'YouTube': 41,
      'Twitter': 28,
      'Reddit': 18,
    };
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
}
