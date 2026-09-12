import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/services/analytics_service.dart';
import 'core/services/daily_notification_service.dart';
import 'features/home/home_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------------------
  // FIREBASE
  // ------------------------------------------------------------

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AnalyticsService.initialize();

  await AnalyticsService.logTestEvent(
    'app_started',
    {
      'platform':
          kIsWeb ? 'web' : defaultTargetPlatform.name,
    },
  );

  // ------------------------------------------------------------
  // ADMOB
  // ------------------------------------------------------------

  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  // ------------------------------------------------------------
  // LOCAL NOTIFICATIONS
  // ------------------------------------------------------------

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
    await AnalyticsService.screen(
      'home',
    );

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
    switch (state) {
      case AppLifecycleState.resumed:
        AnalyticsService.appForegrounded();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        AnalyticsService.appBackgrounded();
        break;

      case AppLifecycleState.inactive:
        break;
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
          analytics:
              AnalyticsService.analytics,
        ),
      ],

      theme: ThemeData(
        useMaterial3: true,
      ),

      home: const HomePage(),
    );
  }
}