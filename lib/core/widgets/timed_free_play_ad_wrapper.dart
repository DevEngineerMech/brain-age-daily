import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'app_interstitial_ad.dart';

class TimedFreePlayAdWrapper extends StatefulWidget {
  final Widget child;

  const TimedFreePlayAdWrapper({
    super.key,
    required this.child,
  });

  @override
  State<TimedFreePlayAdWrapper> createState() => _TimedFreePlayAdWrapperState();
}

class _TimedFreePlayAdWrapperState extends State<TimedFreePlayAdWrapper> {
  final Random _random = Random();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    AppInterstitialAd.load();
    _scheduleNextAd();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _randomDelay() {
    final int seconds = 60 + _random.nextInt(61); // 60–120 seconds
    return Duration(seconds: seconds);
  }

  void _scheduleNextAd() {
    _timer?.cancel();

    _timer = Timer(_randomDelay(), () async {
      if (!mounted) return;

      await AppInterstitialAd.show(context);

      if (!mounted) return;
      _scheduleNextAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}