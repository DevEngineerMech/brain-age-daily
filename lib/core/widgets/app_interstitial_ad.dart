import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppInterstitialAd {
  static InterstitialAd? _ad;
  static bool _isLoading = false;

  static final ValueNotifier<bool> isShowingAd = ValueNotifier<bool>(false);

  static const String _testAdUnitId =
      'ca-app-pub-3940256099942544/4411468910';

  static void load() {
    if (_isLoading || _ad != null) return;

    _isLoading = true;

    InterstitialAd.load(
      adUnitId: _testAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _ad = ad;
          _isLoading = false;
          debugPrint('Interstitial loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _ad = null;
          _isLoading = false;
          debugPrint('Interstitial failed: $error');
        },
      ),
    );
  }

  static Future<void> show(BuildContext context) async {
    if (_ad == null) {
      load();
      return;
    }

    final InterstitialAd adToShow = _ad!;
    _ad = null;

    final Completer<void> completer = Completer<void>();

    adToShow.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        isShowingAd.value = true;
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        isShowingAd.value = false;
        if (!completer.isCompleted) completer.complete();
        load();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        isShowingAd.value = false;
        if (!completer.isCompleted) completer.complete();
        load();
      },
    );

    adToShow.show();
    await completer.future;
  }
}