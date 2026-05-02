import 'package:flutter/material.dart';

class AppColors {
  static const Color bgStart = Color(0xFF5E5CE6);
  static const Color bgEnd = Color(0xFF7B61FF);

  static const Color white = Colors.white;
  static const Color card = Color(0xFFF7F5FB);
  static const Color textDark = Color(0xFF202336);
  static const Color textLight = Color(0xFF7C8199);

  static const Color primary = Color(0xFF5B5BE6);
  static const Color secondary = Color(0xFF8A7CFF);

  static const Color teal = Color(0xFF25B7C9);
  static const Color green = Color(0xFF1EB980);
  static const Color orange = Color(0xFFF5A623);
  static const Color pink = Color(0xFFE95A8B);
  static const Color purple = Color(0xFF8C6BFF);
  static const Color blue = Color(0xFF4B82F1);

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [bgStart, bgEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}