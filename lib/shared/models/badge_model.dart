// lib/shared/models/badge_model.dart

class BadgeModel {
  final String emoji;
  final String name;
  final String description;
  final String requirement;
  final bool earned;

  const BadgeModel({
    required this.emoji,
    required this.name,
    required this.description,
    required this.requirement,
    required this.earned,
  });
}

/// Compute the full badge list from current state
List<BadgeModel> computeBadges({
  required int currentStreak,
  required int longestStreak,
  required int sessionsToday,
  required int focusMinutesToday,
  required int totalSavedHours,
}) {
  return [
    BadgeModel(
      emoji: '🌱',
      name: 'First Step',
      description: 'Completed your first focus session',
      requirement: '1 session',
      earned: sessionsToday >= 1 || totalSavedHours >= 1,
    ),
    BadgeModel(
      emoji: '🔥',
      name: '7-Day Streak',
      description: 'Stayed consistent for a full week',
      requirement: '7-day streak',
      earned: currentStreak >= 7,
    ),
    BadgeModel(
      emoji: '⚡',
      name: 'Focus Master',
      description: 'Clocked 60+ focus minutes in a day',
      requirement: '60 min today',
      earned: focusMinutesToday >= 60,
    ),
    BadgeModel(
      emoji: '🌙',
      name: 'Night Owl Tamed',
      description: 'Kept a 3-day streak going',
      requirement: '3-day streak',
      earned: longestStreak >= 3,
    ),
    BadgeModel(
      emoji: '🧘',
      name: 'Zen Mode',
      description: 'Meditated on consistency for 14 days',
      requirement: '14-day streak',
      earned: currentStreak >= 14,
    ),
    BadgeModel(
      emoji: '💎',
      name: 'Deep Worker',
      description: 'Completed 4+ sessions in one day',
      requirement: '4 sessions today',
      earned: sessionsToday >= 4,
    ),
    BadgeModel(
      emoji: '⏰',
      name: 'Time Saver',
      description: 'Saved 10+ hours total',
      requirement: '10 hours saved',
      earned: totalSavedHours >= 10,
    ),
    BadgeModel(
      emoji: '🏆',
      name: '30-Day Legend',
      description: 'An unstoppable 30-day run',
      requirement: '30-day streak',
      earned: currentStreak >= 30,
    ),
  ];
}