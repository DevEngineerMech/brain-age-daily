import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/admob_service.dart';

class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key});

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  bool _requested = false;

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;

      if (!kIsWeb && AdMobService.isIOS) {
        setState(() {
          _requested = true;
        });

        await AdMobService.loadBannerAd();

        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _debugBox(
        color: const Color(0xFF70757A),
        text: '🌐 Web mode • ads disabled',
      );
    }

    if (!AdMobService.isIOS) {
      return _debugBox(
        color: const Color(0xFF70757A),
        text: 'Ads disabled on this platform',
      );
    }

    if (AdMobService.isBannerLoaded && AdMobService.bannerAd != null) {
      return Container(
        width: AdMobService.bannerAd!.size.width.toDouble(),
        height: AdMobService.bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: AdMobService.bannerAd!),
      );
    }

    if (_requested || AdMobService.isBannerLoading) {
      return _debugBox(
        color: const Color(0xFF22C55E),
        text: '🟢 Banner ad requested',
      );
    }

    return _debugBox(
      color: const Color(0xFFEF4444),
      text: '🔴 Banner ad not requested',
    );
  }

  Widget _debugBox({
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}