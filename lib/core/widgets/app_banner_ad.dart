import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/analytics_service.dart';

class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key});

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  static const String _adUnitId =
      'ca-app-pub-6683665885451621/5649466122';

  @override
  void initState() {
    super.initState();

    if (kIsWeb) return;

    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd?.dispose();

    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          AnalyticsService.adEvent(
            action: 'loaded',
            format: 'banner',
            placement: 'app_banner',
          );

          debugPrint('Banner loaded');

          if (mounted) {
            setState(() {
              _loaded = true;
            });
          }
        },

        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');

          AnalyticsService.adEvent(
            action: 'load_failed',
            format: 'banner',
            placement: 'app_banner',
            error: error.toString(),
          );

          ad.dispose();

          if (mounted) {
            setState(() {
              _loaded = false;
              _bannerAd = null;
            });
          }

          Future.delayed(
            const Duration(seconds: 10),
            () {
              if (!mounted) return;
              _loadBanner();
            },
          );
        },

        onAdImpression: (ad) {
          AnalyticsService.adEvent(
            action: 'impression',
            format: 'banner',
            placement: 'app_banner',
          );
        },

        onPaidEvent: (
          Ad ad,
          double valueMicros,
          PrecisionType precision,
          String currencyCode,
        ) {
          AnalyticsService.adRevenue(
            format: 'banner',
            placement: 'app_banner',
            valueMicros: valueMicros.round(),
            currencyCode: currencyCode,
            precision: precision.name,
          );
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    if (!_loaded || _bannerAd == null) {
      return const SizedBox(height: 0);
    }

    return SafeArea(
      top: false,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(
          ad: _bannerAd!,
        ),
      ),
    );
  }
}