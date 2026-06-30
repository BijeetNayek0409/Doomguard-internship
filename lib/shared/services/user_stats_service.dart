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
    return {
      'currentStreak': data['currentStreak'] ?? 0,
      'longestStreak': data['longestStreak'] ?? 0,
      'sessionsToday': data['sessionsToday'] ?? 0,
      'focusMinutesToday': data['focusMinutesToday'] ?? 0,
      'totalSavedHours': data['totalSavedHours'] ?? 0,
    };
  }
}