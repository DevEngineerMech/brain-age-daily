import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/analytics_service.dart';

class AppInterstitialAd {
  static InterstitialAd? _ad;
  static bool _isLoading = false;

  static final ValueNotifier<bool> isShowingAd = ValueNotifier<bool>(false);
  static const String _adUnitId = 'ca-app-pub-6683665885451621/8459172347';

  static void load() {
    if (kIsWeb) return;
    if (_isLoading || _ad != null) return;
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _ad = ad;
          _isLoading = false;
          AnalyticsService.adEvent(action: 'loaded', format: 'interstitial', placement: 'preloaded');
          ad.onPaidEvent = (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
            AnalyticsService.adRevenue(
              format: 'interstitial',
              placement: 'interstitial',
              valueMicros: valueMicros.round(),
              currencyCode: currencyCode,
              precision: precision.name,
            );
          };
        },
        onAdFailedToLoad: (LoadAdError error) {
          _ad = null;
          _isLoading = false;
          AnalyticsService.adEvent(action: 'load_failed', format: 'interstitial', placement: 'preloaded', error: error.toString());
          Future.delayed(const Duration(seconds: 10), load);
        },
      ),
    );
  }

  static Future<void> show(BuildContext context, {String placement = 'unknown'}) async {
    if (kIsWeb) return;
    if (_ad == null) {
      AnalyticsService.adEvent(action: 'not_ready', format: 'interstitial', placement: placement);
      load();
      return;
    }

    final InterstitialAd adToShow = _ad!;
    _ad = null;
    final Completer<void> completer = Completer<void>();

    adToShow.onPaidEvent = (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
      AnalyticsService.adRevenue(
        format: 'interstitial',
        placement: placement,
        valueMicros: valueMicros.round(),
        currencyCode: currencyCode,
        precision: precision.name,
      );
    };

    adToShow.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        isShowingAd.value = true;
        AnalyticsService.adEvent(action: 'shown', format: 'interstitial', placement: placement);
      },
      onAdImpression: (_) {
        AnalyticsService.adEvent(action: 'impression', format: 'interstitial', placement: placement);
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        isShowingAd.value = false;
        AnalyticsService.adEvent(action: 'dismissed', format: 'interstitial', placement: placement);
        load();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        isShowingAd.value = false;
        AnalyticsService.adEvent(action: 'show_failed', format: 'interstitial', placement: placement, error: error.toString());
        load();
        if (!completer.isCompleted) completer.complete();
      },
    );

    adToShow.show();
    await completer.future;
  }
}
