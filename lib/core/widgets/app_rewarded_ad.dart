import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppRewardedAd {
  static RewardedAd? _ad;
  static bool _isLoading = false;

  static const String adUnitId = 'ca-app-pub-6683665885451621/5990510071';

  static bool get isReady => _ad != null;

  static void load() {
    if (kIsWeb) return;
    if (_isLoading || _ad != null) return;

    _isLoading = true;

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _ad = ad;
          _isLoading = false;
          debugPrint('Rewarded ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _ad = null;
          _isLoading = false;
          debugPrint('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  static Future<bool> show() async {
    if (kIsWeb) {
      return true;
    }

    final RewardedAd? ad = _ad;

    if (ad == null) {
      load();
      return false;
    }

    _ad = null;

    bool earnedReward = false;
    final Completer<bool> completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        load();

        if (!completer.isCompleted) {
          completer.complete(earnedReward);
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        load();

        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        earnedReward = true;
      },
    );

    return completer.future;
  }
}