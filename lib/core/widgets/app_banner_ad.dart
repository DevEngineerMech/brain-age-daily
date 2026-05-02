import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key});

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  bool _requestSent = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  String get _adUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/2934735716';
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/6300978111';
      default:
        return 'ca-app-pub-3940256099942544/6300978111';
    }
  }

  void _loadAd() {
    if (kIsWeb) {
      return;
    }

    _requestSent = true;

    final BannerAd banner = BannerAd(
      size: AdSize.banner,
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _loaded = true;
            _failed = false;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _loaded = false;
            _failed = true;
          });
        },
      ),
    );

    banner.load();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _statusBox(
        background: const Color(0xFF5F6368),
        border: const Color(0xFF80868B),
        text: 'Web mode · ads disabled',
        icon: Icons.language,
      );
    }

    if (_loaded && _bannerAd != null) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    if (_failed) {
      return _statusBox(
        background: const Color(0xFF7A1F1F),
        border: const Color(0xFFFF5A5A),
        text: 'Ad request failed',
        icon: Icons.error_outline,
      );
    }

    if (_requestSent) {
      return _statusBox(
        background: const Color(0xFF184D2A),
        border: const Color(0xFF39D98A),
        text: 'Ad request sent · waiting for fill',
        icon: Icons.check_circle_outline,
      );
    }

    return _statusBox(
      background: const Color(0xFF2D3748),
      border: const Color(0xFF4A5568),
      text: 'Preparing ad slot',
      icon: Icons.hourglass_bottom,
    );
  }

  Widget _statusBox({
    required Color background,
    required Color border,
    required String text,
    required IconData icon,
  }) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}