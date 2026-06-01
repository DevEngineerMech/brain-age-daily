import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
          debugPrint('Interstitial loaded');
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Interstitial failed: $error');
          _ad = null;
          _isLoading = false;

          Future.delayed(const Duration(seconds: 10), () {
            load();
          });
        },
      ),
    );
  }

  static Future<void> show(BuildContext context) async {
    if (kIsWeb) return;

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
        load();

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('Interstitial show failed: $error');
        ad.dispose();
        isShowingAd.value = false;
        load();

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    adToShow.show();

    await completer.future;
  }
}