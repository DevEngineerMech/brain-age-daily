import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/analytics_service.dart';

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
          AnalyticsService.adEvent(action: 'loaded', format: 'rewarded', placement: 'preloaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _ad = null;
          _isLoading = false;
          AnalyticsService.adEvent(action: 'load_failed', format: 'rewarded', placement: 'preloaded', error: error.toString());
        },
      ),
    );
  }

  static Future<bool> show({String placement = 'unknown'}) async {
    if (kIsWeb) return true;
    final RewardedAd? ad = _ad;
    if (ad == null) {
      AnalyticsService.adEvent(action: 'not_ready', format: 'rewarded', placement: placement);
      load();
      return false;
    }

    _ad = null;
    bool earnedReward = false;
    final Completer<bool> completer = Completer<bool>();

    ad.onPaidEvent = (Ad ad, double valueMicros, PrecisionType precision, String currencyCode) {
      AnalyticsService.adRevenue(
        format: 'rewarded', placement: placement, valueMicros: valueMicros.round(),
        currencyCode: currencyCode, precision: precision.name,
      );
    };

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => AnalyticsService.adEvent(action: 'shown', format: 'rewarded', placement: placement),
      onAdImpression: (_) => AnalyticsService.adEvent(action: 'impression', format: 'rewarded', placement: placement),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        AnalyticsService.adEvent(action: 'dismissed', format: 'rewarded', placement: placement);
        load();
        if (!completer.isCompleted) completer.complete(earnedReward);
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        AnalyticsService.adEvent(action: 'show_failed', format: 'rewarded', placement: placement, error: error.toString());
        load();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      earnedReward = true;
      AnalyticsService.adEvent(action: 'reward_earned', format: 'rewarded', placement: placement);
    });
    return completer.future;
  }
}
