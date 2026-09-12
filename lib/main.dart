import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/services/daily_notification_service.dart';
import 'features/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Make sure Analytics collection is enabled.
  await FirebaseAnalytics.instance
      .setAnalyticsCollectionEnabled(true);

  // Explicit launch event so we can confirm Firebase
  // is receiving data from TestFlight builds.
  await FirebaseAnalytics.instance.logEvent(
    name: 'app_started',
  );

  // AdMob
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  // Local notifications only.
  // This is NOT the old owner notification system.
  if (!kIsWeb) {
    await DailyNotificationService.initialize();
  }

  runApp(
    const BrainAgeDailyApp(),
  );
}

class BrainAgeDailyApp extends StatefulWidget {
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
  final FirebaseAnalytics _analytics =
      FirebaseAnalytics.instance;

  bool _notificationSetupStarted = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _afterFirstFrame();
      },
    );
  }

  Future<void> _afterFirstFrame() async {
    // Log the initial home screen.
    await _analytics.logScreenView(
      screenName: 'home',
      screenClass: 'HomePage',
    );

    // Set up the normal user-facing daily reminders.
    if (!kIsWeb) {
      await _setupNotifications();
    }
  }

  Future<void> _setupNotifications() async {
    if (_notificationSetupStarted) {
      return;
    }

    _notificationSetupStarted = true;

    await DailyNotificationService
        .requestPermissionAndSchedule();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _analytics.logEvent(
        name: 'app_foregrounded',
      );
    }

    if (state == AppLifecycleState.paused) {
      _analytics.logEvent(
        name: 'app_backgrounded',
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'Brain Age Daily',
      debugShowCheckedModeBanner: false,

      navigatorObservers: [
        FirebaseAnalyticsObserver(
          analytics: _analytics,
        ),
      ],

      theme: ThemeData(
        useMaterial3: true,
      ),

      home: const HomePage(),
    );
  }
}