import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  AdMobService._();

  static BannerAd? _bannerAd;
  static bool _isBannerLoaded = false;
  static bool _isBannerLoading = false;

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialReady = false;
  static bool _isInterstitialLoading = false;

  static bool _initialized = false;

  static const String _iosBannerAdUnitId =
      'ca-app-pub-6683665885451621/56494';

  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-6683665885451621/84591';

  static bool get isWeb => kIsWeb;

  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  static bool get canUseRealAds {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  static String get bannerAdUnitId {
    if (!canUseRealAds) return '';
    return _iosBannerAdUnitId;
  }

  static String get interstitialAdUnitId {
    if (!canUseRealAds) return '';
    return _iosInterstitialAdUnitId;
  }

  static BannerAd? get bannerAd => _bannerAd;

  static bool get isBannerLoaded => _isBannerLoaded;

  static bool get isBannerLoading => _isBannerLoading;

  static bool get isInterstitialReady => _isInterstitialReady;

  static bool get isInterstitialLoading => _isInterstitialLoading;

  static Future<void> initialize() async {
    if (!canUseRealAds) return;
    if (_initialized) return;

    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  static Future<void> loadBannerAd() async {
    if (!canUseRealAds) return;
    if (_isBannerLoading) return;
    if (_isBannerLoaded && _bannerAd != null) return;

    await initialize();

    if (!_initialized) return;
    if (bannerAdUnitId.isEmpty) return;

    _isBannerLoading = true;
    _isBannerLoaded = false;

    try {
      _bannerAd?.dispose();

      final BannerAd banner = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            _bannerAd = ad as BannerAd;
            _isBannerLoaded = true;
            _isBannerLoading = false;
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            _bannerAd = null;
            _isBannerLoaded = false;
            _isBannerLoading = false;
          },
        ),
      );

      _bannerAd = banner;
      await banner.load();
    } catch (_) {
      _bannerAd = null;
      _isBannerLoaded = false;
      _isBannerLoading = false;
    }
  }

  static void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
    _isBannerLoading = false;
  }

  static Future<void> loadInterstitialAd() async {
    if (!canUseRealAds) return;
    if (_isInterstitialLoading) return;
    if (_isInterstitialReady && _interstitialAd != null) return;

    await initialize();

    if (!_initialized) return;
    if (interstitialAdUnitId.isEmpty) return;

    _isInterstitialLoading = true;
    _isInterstitialReady = false;

    try {
      await InterstitialAd.load(
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
    } catch (_) {
      _interstitialAd = null;
      _isInterstitialReady = false;
      _isInterstitialLoading = false;
    }
  }

  static Future<bool> showInterstitialAd() async {
    if (!canUseRealAds) return false;

    if (_interstitialAd == null || !_isInterstitialReady) {
      await loadInterstitialAd();
      return false;
    }

    try {
      final InterstitialAd ad = _interstitialAd!;

      _interstitialAd = null;
      _isInterstitialReady = false;
      _isInterstitialLoading = false;

      await ad.show();
      return true;
    } catch (_) {
      _interstitialAd = null;
      _isInterstitialReady = false;
      _isInterstitialLoading = false;
      await loadInterstitialAd();
      return false;
    }
  }
}