import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'analytics_service.dart';
import 'daily_progress_service.dart';

class _NotificationMessage {
  final String title;
  final String body;
  final String variant;

  const _NotificationMessage({
    required this.title,
    required this.body,
    required this.variant,
  });
}

class DailyNotificationService {
  DailyNotificationService._();

  static final FlutterLocalNotificationsPlugin
      _notifications =
      FlutterLocalNotificationsPlugin();

  static const String
      notificationEnabledKey =
      'daily_notifications_enabled';

  static bool _initialized = false;

  static const int _morningBaseId =
      1000;

  static const int _eveningBaseId =
      2000;

  static const List<_NotificationMessage>
      _notStartedMessages = [
    _NotificationMessage(
      title: '🧠 Your brain workout is ready',
      body:
          'Take today’s Brain Age Daily challenge and see how sharp you are.',
      variant: 'not_started_01',
    ),
    _NotificationMessage(
      title: 'Can you beat yesterday?',
      body:
          'Your Daily Brain Check is waiting.',
      variant: 'not_started_02',
    ),
    _NotificationMessage(
      title: 'A fresh challenge is ready',
      body:
          'Five quick games. One new Brain Age.',
      variant: 'not_started_03',
    ),
    _NotificationMessage(
      title: 'How sharp are you today?',
      body:
          'Take today’s Daily Brain Check and find out.',
      variant: 'not_started_04',
    ),
    _NotificationMessage(
      title: 'Time for today’s brain workout',
      body:
          'Your challenge only takes a few minutes.',
      variant: 'not_started_05',
    ),
    _NotificationMessage(
      title: '🧠 Brain Age check',
      body:
          'Think you can improve your result today?',
      variant: 'not_started_06',
    ),
    _NotificationMessage(
      title: 'Keep your streak alive 🔥',
      body:
          'Today’s challenge is ready when you are.',
      variant: 'not_started_07',
    ),
    _NotificationMessage(
      title: 'Ready for a quick challenge?',
      body:
          'Test your memory, speed and focus today.',
      variant: 'not_started_08',
    ),
    _NotificationMessage(
      title: 'Your Brain Age can change',
      body:
          'Complete today’s challenge to reveal your latest result.',
      variant: 'not_started_09',
    ),
    _NotificationMessage(
      title: 'Don’t skip brain day 🧠',
      body:
          'Your Daily Brain Check is waiting.',
      variant: 'not_started_10',
    ),
    _NotificationMessage(
      title: 'Today’s test is ready',
      body:
          'See if you can improve your score.',
      variant: 'not_started_11',
    ),
    _NotificationMessage(
      title: 'Quick brain check?',
      body:
          'A few minutes is all it takes.',
      variant: 'not_started_12',
    ),
    _NotificationMessage(
      title: 'Challenge yourself today',
      body:
          'Your new Daily Brain Check is available.',
      variant: 'not_started_13',
    ),
    _NotificationMessage(
      title: 'Your brain has a score to beat',
      body:
          'Jump into today’s challenge.',
      variant: 'not_started_14',
    ),
    _NotificationMessage(
      title: 'Let’s see today’s Brain Age',
      body:
          'Complete your five daily games.',
      variant: 'not_started_15',
    ),
  ];

  static const List<_NotificationMessage>
      _incompleteMessages = [
    _NotificationMessage(
      title: 'You almost finished 👀',
      body:
          'Come back and complete today’s Daily Brain Check.',
      variant: 'incomplete_01',
    ),
    _NotificationMessage(
      title: 'Your challenge is unfinished',
      body:
          'Pick up where you left off.',
      variant: 'incomplete_02',
    ),
    _NotificationMessage(
      title: 'Don’t leave your score unfinished',
      body:
          'Finish today’s challenge and reveal your Brain Age.',
      variant: 'incomplete_03',
    ),
    _NotificationMessage(
      title: 'You started strong 🧠',
      body:
          'Come back and finish your remaining games.',
      variant: 'incomplete_04',
    ),
    _NotificationMessage(
      title: 'So close!',
      body:
          'Finish today’s Brain Check to get your final result.',
      variant: 'incomplete_05',
    ),
    _NotificationMessage(
      title: 'Your Brain Age is still hidden',
      body:
          'Complete the rest of today’s challenge to reveal it.',
      variant: 'incomplete_06',
    ),
    _NotificationMessage(
      title: 'Finish what you started',
      body:
          'Your Daily Brain Check is waiting.',
      variant: 'incomplete_07',
    ),
    _NotificationMessage(
      title: 'A few games left',
      body:
          'Come back and finish today’s challenge.',
      variant: 'incomplete_08',
    ),
  ];

  static const List<_NotificationMessage>
      _completedMessages = [
    _NotificationMessage(
      title: 'Nice work today 🧠',
      body:
          'Fancy another round? Try a Free Play game.',
      variant: 'completed_01',
    ),
    _NotificationMessage(
      title: 'Daily challenge complete ✅',
      body:
          'Keep training in Free Play if you want another test.',
      variant: 'completed_02',
    ),
    _NotificationMessage(
      title: 'You got today’s Brain Age',
      body:
          'Try Free Play and sharpen your strongest skills.',
      variant: 'completed_03',
    ),
  ];

  static Future<void>
      initialize() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform !=
        TargetPlatform.iOS) {
      return;
    }

    if (_initialized) return;

    tz.initializeTimeZones();

    try {
      final String localTimezone =
          await FlutterTimezone
              .getLocalTimezone();

      tz.setLocalLocation(
        tz.getLocation(
          localTimezone,
        ),
      );
    } catch (_) {
      tz.setLocalLocation(
        tz.getLocation(
          'Europe/London',
        ),
      );
    }

    const DarwinInitializationSettings
        iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const InitializationSettings
        initializationSettings =
        InitializationSettings(
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          _onNotificationTapped,
    );

    final NotificationAppLaunchDetails?
        launchDetails =
        await _notifications
            .getNotificationAppLaunchDetails();

    if (launchDetails
                ?.didNotificationLaunchApp ==
            true &&
        launchDetails
                ?.notificationResponse
                ?.payload !=
            null) {
      await _processPayload(
        launchDetails!
            .notificationResponse!
            .payload!,
      );
    }

    _initialized = true;
  }

  static Future<void>
      _onNotificationTapped(
    NotificationResponse response,
  ) async {
    final String? payload =
        response.payload;

    if (payload == null ||
        payload.isEmpty) {
      return;
    }

    await _processPayload(
      payload,
    );
  }

  static Future<void>
      _processPayload(
    String payload,
  ) async {
    final List<String> parts =
        payload.split('|');

    if (parts.length < 4) return;

    await AnalyticsService
        .notificationOpened(
      slot: parts[1],
      type: parts[2],
      variant: parts[3],
    );
  }

  static Future<bool>
      requestPermission() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform !=
        TargetPlatform.iOS) {
      return false;
    }

    await initialize();

    final IOSFlutterLocalNotificationsPlugin?
        iosPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

    final bool? granted =
        await iosPlugin
            ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return granted ?? false;
  }

  static Future<void>
      requestPermissionAndSchedule() async {
    if (kIsWeb) return;

    final bool granted =
        await requestPermission();

    final SharedPreferences prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setBool(
      notificationEnabledKey,
      granted,
    );

    if (!granted) return;

    await scheduleDailyReminders();
  }

  static Future<void>
      scheduleDailyReminder() async {
    await scheduleDailyReminders();
  }

  static Future<void>
      rescheduleDailyReminder() async {
    await scheduleDailyReminders();
  }

  static Future<void>
      scheduleDailyReminders() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform !=
        TargetPlatform.iOS) {
      return;
    }

    await initialize();

    final SharedPreferences prefs =
        await SharedPreferences
            .getInstance();

    final bool enabled =
        prefs.getBool(
              notificationEnabledKey,
            ) ??
            false;

    if (!enabled) return;

    await _cancelScheduledIds();

    final DailyProgress progress =
        await DailyProgressService
            .getTodayProgress();

    final tz.TZDateTime now =
        tz.TZDateTime.now(
      tz.local,
    );

    // Schedule seven days ahead.
    for (int offset = 0;
        offset < 7;
        offset++) {
      final tz.TZDateTime day =
          tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + offset,
      );

      final bool isToday =
          offset == 0;

      final DailyProgress
          stateForDay =
          isToday
              ? progress
              : const DailyProgress(
                  started: false,
                  completed: false,
                  gamesCompleted: 0,
                );

      await _scheduleOne(
        id:
            _morningBaseId +
                offset,
        date: day,
        hour: 10,
        slot: '10am',
        progress: stateForDay,
        offset: offset,
      );

      await _scheduleOne(
        id:
            _eveningBaseId +
                offset,
        date: day,
        hour: 18,
        slot: '6pm',
        progress: stateForDay,
        offset:
            offset + 31,
      );
    }
  }

  static Future<void> _scheduleOne({
    required int id,
    required tz.TZDateTime date,
    required int hour,
    required String slot,
    required DailyProgress progress,
    required int offset,
  }) async {
    final tz.TZDateTime now =
        tz.TZDateTime.now(
      tz.local,
    );

    final tz.TZDateTime scheduled =
        tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
    );

    if (!scheduled.isAfter(now)) {
      return;
    }

    final _NotificationMessage message =
        _chooseMessage(
      progress,
      scheduled,
      offset,
    );

    final String type =
        progress.completed
            ? 'completed'
            : progress.started
                ? 'incomplete'
                : 'not_started';

    String body = message.body;

    if (type == 'incomplete') {
      final int remaining =
          max(
        0,
        5 -
            progress
                .gamesCompleted,
      );

      if (remaining == 1) {
        body =
            'Only 1 game left — finish today’s Brain Check.';
      } else if (remaining > 1) {
        body =
            'Only $remaining games left — finish today’s Brain Check.';
      }
    }

    const DarwinNotificationDetails
        iosDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details =
        NotificationDetails(
      iOS: iosDetails,
    );

    final String payload =
        'brain_age_daily|$slot|$type|${message.variant}';

    await _notifications.zonedSchedule(
      id,
      message.title,
      body,
      scheduled,
      details,
      payload: payload,
      androidScheduleMode:
          AndroidScheduleMode
              .inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime,
    );

    await AnalyticsService
        .notificationScheduled(
      slot: slot,
      type: type,
      variant: message.variant,
    );
  }

  static _NotificationMessage
      _chooseMessage(
    DailyProgress progress,
    tz.TZDateTime scheduled,
    int extraSeed,
  ) {
    final List<_NotificationMessage>
        options;

    if (progress.completed) {
      options =
          _completedMessages;
    } else if (progress.started) {
      options =
          _incompleteMessages;
    } else {
      options =
          _notStartedMessages;
    }

    final int seed =
        scheduled.year *
                10000 +
            scheduled.month *
                100 +
            scheduled.day +
            extraSeed;

    final Random random =
        Random(seed);

    return options[
        random.nextInt(
      options.length,
    )];
  }

  static Future<void>
      _cancelScheduledIds() async {
    for (int i = 0;
        i < 7;
        i++) {
      await _notifications.cancel(
        _morningBaseId + i,
      );

      await _notifications.cancel(
        _eveningBaseId + i,
      );
    }
  }

  static Future<void>
      cancelDailyReminder() async {
    if (kIsWeb) return;

    await initialize();

    await _cancelScheduledIds();
  }
}