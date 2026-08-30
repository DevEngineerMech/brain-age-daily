import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailyNotificationService {
  DailyNotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1001;

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

  static Future<void>
      requestPermissionAndSchedule() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    await initialize();

    final bool granted =
        await requestPermission();

    if (!granted) {
      debugPrint(
        'Notification permission was not granted.',
      );

      return;
    }

    await scheduleDailyReminder();
  }

  static Future<void>
      scheduleDailyReminder() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    await initialize();

    await _notifications.cancel(
      _dailyReminderId,
    );

    final tz.TZDateTime nextReminder =
        _nextReminderTime(
      hour: 19,
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

    await _notifications.zonedSchedule(
      _dailyReminderId,
      '🧠 Your Brain Check is ready',
      'Take today’s Brain Age Daily challenge and keep your streak going!',
      nextReminder,
      notificationDetails,
      payload: 'daily_brain_check',
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time,
    );

    debugPrint(
      'Daily notification scheduled for $nextReminder',
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

  static Future<void>
      cancelDailyReminder() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    await initialize();

    await _notifications.cancel(
      _dailyReminderId,
    );

    debugPrint(
      'Daily reminder cancelled.',
    );
  }

  static Future<void>
      rescheduleDailyReminder() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    await initialize();

    await scheduleDailyReminder();
  }
}