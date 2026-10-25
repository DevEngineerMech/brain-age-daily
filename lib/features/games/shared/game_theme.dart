
import 'package:flutter/material.dart';

class GameTheme {
  GameTheme._();

  // Matches the existing Daily Brain Check colours.
  static const Color background = Color(0xFF0C0929);
  static const Color panel = Color(0xFF1A1646);
  static const Color panelLight = Color(0xFF30245C);

  static const Color purple = Color(0xFF8A4CFA);
  static const Color cyan = Color(0xFF42D9D0);
  static const Color gold = Color(0xFFFFC75D);
  static const Color green = Color(0xFF4BE09D);
  static const Color red = Color(0xFFFF6589);

  static const Color muted = Color(0xFFC5B9DF);
  static const Color border = Color(0xFF59488D);

  static const LinearGradient backgroundGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E104A),
      Color(0xFF080D2A),
      Color(0xFF100A2F),
    ],
  );

  static BoxDecoration card({
    Color? accent,
    double radius = 22,
  }) {
    final color = accent ?? purple;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(panel, color, 0.18)!,
          panel,
        ],
      ),
      border: Border.all(
        color: color.withOpacity(0.56),
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.08),
          blurRadius: 18,
        ),
      ],
    );
  }
}
