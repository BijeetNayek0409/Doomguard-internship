
// lib/shared/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'doomguard_alerts',
      'DoomGuard Alerts',
      channelDescription: 'Notifications for usage limits and breaks',
      importance: importance,
      priority: priority,
    );
    final NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(id, title, body, platformDetails);
  }

  // ── Tiered daily limit nudges (id 10x) ─────────────────────────────────

  /// Tier 1 — at 50% of daily limit (gentle)
  Future<void> showLimitWarningGentle(String appName, int limitMinutes) async {
    await showNotification(
      id: 101,
      title: '📱 Halfway there — $appName',
      body:
      "You've used $appName for ${limitMinutes ~/ 2} min. Daily limit is ${limitMinutes} min.",
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
  }

  /// Tier 2 — at 80% of daily limit (moderate)
  Future<void> showLimitWarningModerate(
      String appName, int usedMinutes, int limitMinutes) async {
    await showNotification(
      id: 102,
      title: '⚠️ Almost at your limit — $appName',
      body:
      "You've used $appName for $usedMinutes min. Only ${limitMinutes - usedMinutes} min left today.",
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  /// Tier 3 — limit exceeded
  Future<void> showLimitExceeded(String appName, int usedMinutes) async {
    await showNotification(
      id: 103,
      title: '🚨 Limit exceeded — $appName',
      body:
      "You've used $appName for $usedMinutes min today. You set a limit for a reason — put it down!",
      importance: Importance.max,
      priority: Priority.max,
    );
  }

  // ── Continuous session nudges (id 20x) ──────────────────────────────────

  /// Fired when user has been on one app continuously without switching
  Future<void> showContinuousSessionNudge(
      String appName, int durationMinutes) async {
    final messages = _continuousMessages(durationMinutes);
    await showNotification(
      id: 201,
      title: messages[0],
      body: messages[1],
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  List<String> _continuousMessages(int minutes) {
    if (minutes >= 90) {
      return [
        '🛑 Still scrolling?',
        "You've been on the same app for $minutes minutes straight. Take a real break.",
      ];
    } else if (minutes >= 60) {
      return [
        '😵 One hour of scrolling',
        "That's 60 minutes on one app. Your brain needs a rest.",
      ];
    } else {
      return [
        '👀 Hey, still there?',
        "You've been scrolling for $minutes minutes without a break.",
      ];
    }
  }

  // ── Total screen time nudges (id 30x) ───────────────────────────────────

  /// Fired when total daily screen time hits a threshold
  Future<void> showTotalScreenTimeNudge(int totalMinutes) async {
    final messages = _totalScreenTimeMessages(totalMinutes);
    await showNotification(
      id: 301,
      title: messages[0],
      body: messages[1],
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  List<String> _totalScreenTimeMessages(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    if (totalMinutes >= 240) {
      return [
        '📵 4+ hours today',
        "You've spent $timeStr on your phone today. DoomGuard thinks you deserve a proper break.",
      ];
    } else if (totalMinutes >= 180) {
      return [
        '⏰ 3 hours of screen time',
        "You're at $timeStr today. Consider setting the phone down for a bit.",
      ];
    } else {
      return [
        '📊 Screen time check',
        "You've used your phone for $timeStr today. Stay mindful!",
      ];
    }
  }

  // ── Legacy methods (kept for compatibility) ──────────────────────────────

  Future<void> showLimitWarning() async {
    await showNotification(
      id: 1,
      title: 'Usage Limit Warning',
      body: 'You have almost reached your daily screen time limits.',
    );
  }

  Future<void> showBreakReminder() async {
    await showNotification(
      id: 2,
      title: 'Take a Break',
      body: 'You have been scrolling for a while. Put the phone down!',
    );
  }
}