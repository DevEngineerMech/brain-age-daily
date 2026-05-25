import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AdMobService {
  static bool _isInitialized = false;
  static bool _isInterstitialReady = false;

  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  static bool get isInterstitialReady => _isInterstitialReady;

  static Future<void> initialize() async {
    _isInitialized = true;
    _isInterstitialReady = false;
  }

  static Future<void> loadBannerAd() async {
    _isInitialized = true;
  }

  static Future<void> loadInterstitialAd() async {
    _isInitialized = true;
    _isInterstitialReady = false;
  }

  static Future<void> showInterstitialAd() async {
    _isInitialized = true;
    _isInterstitialReady = false;
  }

  static void disposeBannerAd() {
    _isInterstitialReady = false;
  }

  static bool get isInitialized => _isInitialized;
}