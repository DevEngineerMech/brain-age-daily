import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/services/analytics_service.dart';
import 'core/services/daily_notification_service.dart';
import 'core/services/owner_analytics_service.dart';

import 'features/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Firebase.initializeApp();

    await AnalyticsService.initialize();

    await MobileAds.instance.initialize();

    await DailyNotificationService.initialize();

    await OwnerAnalyticsService.initialize();
  }

  runApp(
    const BrainAgeDailyApp(),
  );
}

class BrainAgeDailyApp
    extends StatefulWidget {
  const BrainAgeDailyApp({
    super.key,
  });

  @override
  State<BrainAgeDailyApp> createState() =>
      _BrainAgeDailyAppState();
}

class _BrainAgeDailyAppState
    extends State<BrainAgeDailyApp>
    with WidgetsBindingObserver {
  bool _notificationSetupStarted =
      false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(
      this,
    );

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        _setupNotifications();
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      this,
    );

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state ==
        AppLifecycleState.resumed) {
      AnalyticsService.appForegrounded();

      DailyNotificationService
          .rescheduleDailyReminder();

      OwnerAnalyticsService
          .resumeSession();
    }

    if (state ==
            AppLifecycleState.paused ||
        state ==
            AppLifecycleState.detached ||
        state ==
            AppLifecycleState.hidden) {
      AnalyticsService.appBackgrounded();

      DailyNotificationService
          .rescheduleDailyReminder();

      OwnerAnalyticsService
          .pauseSession();
    }
  }

  Future<void> _setupNotifications() async {
    if (_notificationSetupStarted) {
      return;
    }

    _notificationSetupStarted = true;

    if (kIsWeb) {
      return;
    }

    await DailyNotificationService
        .requestPermissionAndSchedule();

    await OwnerAnalyticsService
        .refreshDeviceToken();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'Brain Age Daily',
      debugShowCheckedModeBanner:
          false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      navigatorObservers: [
        if (!kIsWeb)
          FirebaseAnalyticsObserver(
            analytics:
                FirebaseAnalytics.instance,
          ),
      ],
      home: const HomePage(),
    );
  }
}