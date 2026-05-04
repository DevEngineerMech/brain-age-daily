import 'package:flutter/material.dart';

class AppBannerAd extends StatelessWidget {
  const AppBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF70757A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Ads temporarily disabled for iOS crash test',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}