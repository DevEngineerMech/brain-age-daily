import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/admob_service.dart';

class AppInterstitialAd {
  static void load() {
    AdMobService.loadInterstitialAd();
  }

  static Future<void> show(BuildContext context) async {
    if (kIsWeb) {
      await _showWebPreviewPopup(context);
      return;
    }

    if (!AdMobService.isIOS) {
      await _showUnsupportedPopup(context);
      return;
    }

    if (AdMobService.isInterstitialReady) {
      await AdMobService.showInterstitialAd();
      return;
    }

    AdMobService.loadInterstitialAd();

    await _showLoadingPopup(context);

    if (AdMobService.isInterstitialReady) {
      await AdMobService.showInterstitialAd();
    }
  }

  static Future<void> _showWebPreviewPopup(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4B0B8F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Text(
            'Interstitial Ad Preview',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.ads_click_rounded,
                color: Color(0xFFFFD247),
                size: 54,
              ),
              SizedBox(height: 14),
              Text(
                'WEB MODE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFD247),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This is where the real AdMob interstitial will show on iPhone/TestFlight.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'No AdMob request is made on web.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD247),
                  foregroundColor: const Color(0xFF35125A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showLoadingPopup(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return AlertDialog(
          backgroundColor: const Color(0xFF4B0B8F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFFFD247),
              ),
              SizedBox(height: 18),
              Text(
                'Loading advert...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _showUnsupportedPopup(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4B0B8F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Text(
            'Ads Disabled',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Interstitial ads are only enabled for iPhone/iOS builds.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD247),
                  foregroundColor: const Color(0xFF35125A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}