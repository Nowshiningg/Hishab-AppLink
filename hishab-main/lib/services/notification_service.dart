import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;

    // Request permissions for Android 13+
    await _requestPermissions();

    // Check and schedule reminder if enabled
    await _checkAndScheduleReminder();
  }

  Future<void> _requestPermissions() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    final iosImplementation = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // Can navigate to specific screen based on payload
  }

  Future<void> _checkAndScheduleReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
    final reminderTime = prefs.getString('reminder_time') ?? '20:00';

    if (remindersEnabled) {
      await scheduleDailyReminder(reminderTime);
    }
  }

  Future<void> scheduleDailyReminder(String time) async {
    // Parse time (format: "HH:MM")
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Cancel existing notifications
    await _notifications.cancel(0);

    // Schedule notification
    await _notifications.zonedSchedule(
      0, // notification id
      'হিসাব Reminder',
      'Don\'t forget to track your expenses today! 📊',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Daily expense tracking reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminder_time', time);
    await prefs.setBool('reminders_enabled', true);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time is in the past, schedule for next day
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders_enabled', false);
  }

  Future<void> showInstantNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Instant Notifications',
      channelDescription: 'Instant notifications for important events',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('reminders_enabled') ?? true;
  }

  Future<String> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('reminder_time') ?? '20:00';
  }

  // ===== Savings Goals Notifications =====

  /// Schedule a goal reminder
  Future<void> scheduleGoalReminder(
    int goalId,
    DateTime reminderTime, {
    String? goalTitle,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'goals_reminders',
      'Savings Goals Reminders',
      channelDescription: 'Reminders for savings goals',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      goalId, // Use goalId as notification ID
      'Savings Goal Reminder',
      goalTitle != null
          ? 'Don\'t forget to save towards "$goalTitle"!'
          : 'Don\'t forget to save towards your goal!',
      tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'goal:$goalId',
    );
  }

  /// Cancel a goal reminder
  Future<void> cancelGoalReminder(int goalId) async {
    await _notifications.cancel(goalId);
  }

  /// Show immediate milestone notification
  Future<void> notifyMilestone(
    int goalId,
    int milestonePercent, {
    String? goalTitle,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'goals_milestones',
      'Savings Milestones',
      channelDescription: 'Notifications for savings goal milestones',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = '🎉 Milestone Reached!';
    final body = goalTitle != null
        ? 'You\'re $milestonePercent% of the way to "$goalTitle"!'
        : 'You\'re $milestonePercent% of the way to your goal!';

    await _notifications.show(
      10000 + goalId, // Offset to avoid collision with reminder IDs
      title,
      body,
      notificationDetails,
      payload: 'milestone:$goalId:$milestonePercent',
    );
  }

  /// Show achievement unlocked notification
  Future<void> notifyAchievement(
    String achievementKey, {
    String? achievementTitle,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'achievements',
      'Achievements',
      channelDescription: 'Achievement unlock notifications',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = '🏆 Achievement Unlocked!';
    final body = achievementTitle ?? 'You\'ve unlocked a new achievement!';

    await _notifications.show(
      achievementKey.hashCode, // Use hash as unique ID
      title,
      body,
      notificationDetails,
      payload: 'achievement:$achievementKey',
    );
  }

  /// Show goal completed celebration notification
  Future<void> notifyGoalCompleted(String goalTitle) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'goals_completed',
      'Goals Completed',
      channelDescription: 'Celebrations for completed goals',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🎊 Goal Completed!',
      'Congratulations! You\'ve reached your goal: "$goalTitle"',
      notificationDetails,
      payload: 'goal_completed',
    );
  }
}

