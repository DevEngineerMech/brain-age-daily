import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static BannerAd? _bannerAd;
  static bool _isBannerLoaded = false;

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialReady = false;
  static bool _isInterstitialLoading = false;

  static bool _initialized = false;

  static String get bannerAdUnitId {
    if (kIsWeb) return '';

    if (Platform.isIOS) {
      return 'ca-app-pub-6683665885451621/56494';
    }

    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';

    if (Platform.isIOS) {
      return 'ca-app-pub-6683665885451621/84591';
    }

    return '';
  }

  static bool get isWeb => kIsWeb;

  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  static bool get isSupportedDevice {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  static bool get isBannerLoaded => _isBannerLoaded;

  static BannerAd? get bannerAd => _bannerAd;

  static bool get isInterstitialReady => _isInterstitialReady;

  static bool get isInterstitialLoading => _isInterstitialLoading;

  static bool get canRequestRealAds {
    if (kIsWeb) return false;
    if (!Platform.isIOS) return false;
    return true;
  }

  static Future<void> initialize() async {
    if (kIsWeb) return;
    if (!Platform.isIOS) return;
    if (_initialized) return;

    await MobileAds.instance.initialize();
    _initialized = true;

    loadBannerAd();
    loadInterstitialAd();
  }

  static void loadBannerAd() {
    if (kIsWeb) return;
    if (!Platform.isIOS) return;
    if (bannerAdUnitId.isEmpty) return;

    _bannerAd?.dispose();
    _isBannerLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          _isBannerLoaded = false;
        },
      ),
    );

    _bannerAd!.load();
  }

  static void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  static void loadInterstitialAd() {
    if (kIsWeb) return;
    if (!Platform.isIOS) return;
    if (interstitialAdUnitId.isEmpty) return;
    if (_isInterstitialLoading) return;
    if (_interstitialAd != null && _isInterstitialReady) return;

    _isInterstitialLoading = true;
    _isInterstitialReady = false;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          _isInterstitialLoading = false;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialReady = false;
              _isInterstitialLoading = false;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (
              InterstitialAd ad,
              AdError error,
            ) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialReady = false;
              _isInterstitialLoading = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isInterstitialReady = false;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  static Future<bool> showInterstitialAd() async {
    if (kIsWeb) return false;
    if (!Platform.isIOS) return false;

    if (_interstitialAd == null || !_isInterstitialReady) {
      loadInterstitialAd();
      return false;
    }

    final InterstitialAd ad = _interstitialAd!;

    _interstitialAd = null;
    _isInterstitialReady = false;
    _isInterstitialLoading = false;

    ad.show();
    return true;
  }
}