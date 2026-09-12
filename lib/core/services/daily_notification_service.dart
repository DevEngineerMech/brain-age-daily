import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailyNotificationService {
  DailyNotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String notificationEnabledKey =
      'daily_notifications_enabled';

  static const int _morningReminderId = 1001;
  static const int _eveningReminderId = 1002;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    if (_initialized) return;

    tz.initializeTimeZones();

    try {
      final String localTimezone =
          await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(
        tz.getLocation(localTimezone),
      );

      debugPrint(
        'Notification timezone: $localTimezone',
      );
    } catch (e) {
      debugPrint(
        'Could not determine local timezone: $e',
      );

      tz.setLocalLocation(
        tz.getLocation('Europe/London'),
      );
    }

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          _onNotificationTapped,
    );

    _initialized = true;
  }

  static void _onNotificationTapped(
    NotificationResponse response,
  ) {
    debugPrint(
      'Notification tapped: ${response.payload}',
    );
  }

  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return false;
    }

    await initialize();

    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

    final bool? granted =
        await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return granted ?? false;
  }

  /// Called when the app starts for the first time.
  ///
  /// If the user accepts Apple's notification permission:
  /// - save the toggle as ON
  /// - schedule 10 AM
  /// - schedule 6 PM
  ///
  /// If they decline:
  /// - save the toggle as OFF
  static Future<bool> requestPermissionAndSchedule() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return false;
    }

    await initialize();

    final bool granted =
        await requestPermission();

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    if (!granted) {
      await prefs.setBool(
        notificationEnabledKey,
        false,
      );

      await cancelDailyReminder();

      debugPrint(
        'Notification permission was not granted.',
      );

      return false;
    }

    await prefs.setBool(
      notificationEnabledKey,
      true,
    );

    await scheduleDailyReminder();

    debugPrint(
      'Notification permission granted. Toggle enabled automatically.',
    );

    return true;
  }

  /// Schedules TWO repeating iOS local notifications:
  ///
  /// 10:00 AM
  /// 6:00 PM
  static Future<void> scheduleDailyReminder() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    await initialize();

    // Remove any old reminders first.
    await cancelDailyReminder();

    final tz.TZDateTime nextMorningReminder =
        _nextReminderTime(
      hour: 10,
      minute: 0,
    );

    final tz.TZDateTime nextEveningReminder =
        _nextReminderTime(
      hour: 18,
      minute: 0,
    );

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(
      iOS: iosDetails,
    );

    // 10:00 AM reminder
    await _notifications.zonedSchedule(
      _morningReminderId,
      '🧠 Your Brain Check is ready',
      'Start your day with today’s Brain Age Daily challenge!',
      nextMorningReminder,
      notificationDetails,
      payload: 'daily_brain_check_morning',
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time,
    );

    // 6:00 PM reminder
    await _notifications.zonedSchedule(
      _eveningReminderId,
      '🧠 Don’t forget your Brain Check',
      'Complete today’s Brain Age Daily challenge and keep your streak going!',
      nextEveningReminder,
      notificationDetails,
      payload: 'daily_brain_check_evening',
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time,
    );

    debugPrint(
      'Morning notification scheduled for $nextMorningReminder',
    );

    debugPrint(
      'Evening notification scheduled for $nextEveningReminder',
    );
  }

  static tz.TZDateTime _nextReminderTime({
    required int hour,
    required int minute,
  }) {
    final tz.TZDateTime now =
        tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled =
        tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }

    return scheduled;
  }

  /// Cancels BOTH daily reminders.
  static Future<void> cancelDailyReminder() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    await initialize();

    await _notifications.cancel(
      _morningReminderId,
    );

    await _notifications.cancel(
      _eveningReminderId,
    );

    debugPrint(
      'Morning and evening daily reminders cancelled.',
    );
  }

  static Future<void> rescheduleDailyReminder() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    await initialize();

    await scheduleDailyReminder();
  }

  static Future<bool> notificationsEnabled() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          notificationEnabledKey,
        ) ??
        false;
  }

  static Future<void> setNotificationsEnabled(
    bool enabled,
  ) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      notificationEnabledKey,
      enabled,
    );
  }
}