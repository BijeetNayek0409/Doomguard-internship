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
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'doomguard_alerts',
      'DoomGuard Alerts',
      channelDescription: 'Notifications for usage limits and breaks',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
    );
  }

  /// App specific week 3 requirement
  Future<void> showLimitWarning() async {
    await showNotification(
      id: 1,
      title: 'Usage Limit Warning',
      body: 'You have almost reached your daily screen time limits.',
    );
  }

  /// App specific week 3 requirement
  Future<void> showBreakReminder() async {
    await showNotification(
      id: 2,
      title: 'Take a Break',
      body: 'You have been scrolling for a while. Put the phone down!',
    );
  }
}
