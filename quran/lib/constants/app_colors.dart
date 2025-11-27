import 'package:flutter/material.dart';

/// Centralized color definitions for the Quran app
class AppColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF1a472a);
  static const Color darkGreen = Color(0xFF0d2818);
  static const Color accentGold = Color(0xFFd4af37);
  static const Color buttonGreen = Color(0xFF1db854);

  // Border Colors
  static const Color borderGreen = Color(0xFF4a7c5e);
  static const Color borderDark = Color(0xFF2a5c3e);

  // Text Colors
  static const Color textWhite = Colors.white;
  static const Color textGray = Color(0xFFb0b0b0);
  static const Color textLightGray = Colors.white70;
  static const Color textDarkGray = Color(0xFF7a9a6b);

  // Background Gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryGreen, darkGreen],
  );

  // Container Colors
  static Color containerBackground = primaryGreen.withOpacity(0.6);
  static Color containerBackgroundLight = primaryGreen.withOpacity(0.3);

  // State Colors
  static const Color errorRed = Colors.red;
  static const Color successGreen = Color(0xFF1db854);
  static const Color warningYellow = Color(0xFFffd700);

  // Opacity helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
