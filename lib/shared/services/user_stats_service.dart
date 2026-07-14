import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatsService {
  final _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<void> syncStreakStats(
      String uid, {
        required int currentStreak,
        required int longestStreak,
        required int totalSavedHours,
      }) async {
    await _userDoc(uid).set({
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalSavedHours': totalSavedHours,
      'statsUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> syncTimerStats(
      String uid, {
        required int sessionsToday,
        required int focusMinutesToday,
      }) async {
    await _userDoc(uid).set({
      'sessionsToday': sessionsToday,
      'focusMinutesToday': focusMinutesToday,
      'statsUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> fetchStats(String uid) async {
    final snap = await _userDoc(uid).get();
    final data = snap.data() ?? {};

    // Weekly reset check happens on read, so the flag is always
    // accurate without needing a scheduled job.
    final freezeAvailable = await _resolveStreakFreeze(uid, data);

    return {
      'currentStreak': data['currentStreak'] ?? 0,
      'longestStreak': data['longestStreak'] ?? 0,
      'sessionsToday': data['sessionsToday'] ?? 0,
      'focusMinutesToday': data['focusMinutesToday'] ?? 0,
      'totalSavedHours': data['totalSavedHours'] ?? 0,
      'streakFreezeAvailable': freezeAvailable,
    };
  }

  /// Checks whether a week has passed since the freeze was last granted,
  /// and resets the flag if so. Returns the current (post-reset) value.
  Future<bool> _resolveStreakFreeze(
      String uid, Map<String, dynamic> data) async {
    final weekStart = (data['freezeWeekStart'] as Timestamp?)?.toDate();
    final now = DateTime.now();

    final needsReset =
        weekStart == null || now.difference(weekStart).inDays >= 7;

    if (needsReset) {
      await _userDoc(uid).set({
        'streakFreezeAvailable': true,
        'freezeWeekStart': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    }

    return data['streakFreezeAvailable'] as bool? ?? true;
  }

  /// Call when a missed day is detected but you want to preserve the streak.
  /// Returns true if a freeze was applied, false if none was available.
  Future<bool> useStreakFreeze(String uid) async {
    final snap = await _userDoc(uid).get();
    final data = snap.data() ?? {};
    final available = await _resolveStreakFreeze(uid, data);

    if (!available) return false;

    await _userDoc(uid).set({
      'streakFreezeAvailable': false,
    }, SetOptions(merge: true));

    return true;
  }
}