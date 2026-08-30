import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/services/daily_notification_service.dart';
import 'features/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  await DailyNotificationService.initialize();

  runApp(const BrainAgeDailyApp());
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
    extends State<BrainAgeDailyApp> {
  bool _notificationSetupStarted = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _setupNotifications();
      },
    );
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Age Daily',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}