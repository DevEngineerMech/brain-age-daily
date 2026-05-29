import 'package:flutter/foundation.dart';

class AdMobService {
  static bool get isIOS => !kIsWeb;
  static bool get isInterstitialReady => false;

  static Future<void> initialize() async {}
  static Future<void> loadBannerAd() async {}
  static Future<void> loadInterstitialAd() async {}
  static Future<void> showInterstitialAd() async {}

  static void disposeBannerAd() {}
}