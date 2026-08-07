import 'package:flutter/material.dart';

/// Central color palette for the app. Import this instead of
/// hardcoding hex values / Colors.deepPurple etc. throughout each
/// screen, so the whole app's look can be adjusted from one place.
class AppColors {
  AppColors._(); // no instances — this is just a namespace of constants

  // Core brand colors
  static const Color primary = Colors.deepPurple;
  static const Color primaryLight = Color(0xFFF3E8FF);

  // Splash screen (black background, cream accents)
  static const Color splashBackground = Colors.black;
  static const Color splashCream = Color(0xFFF5EFDF);

  // Main app surfaces
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF7F7F9); // light grey cards
  static const Color border = Color(0xFFEEEEEE); // Colors.grey.shade200

  // Text
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF757575); // Colors.grey.shade600

  // Recording screen (black background, cyan accents)
  static const Color recordingBackground = Colors.black;
  static const Color recordingAccent = Colors.cyanAccent;

  // Status / feedback colors
  static const Color success = Colors.green;
  static const Color warning = Colors.amber;
  static const Color error = Colors.redAccent;
  static const Color info = Colors.blueAccent;

  /// Score-based color, used consistently across Home, Progress,
  /// and Results History wherever a score needs a color indicator.
  static Color forScore(int score) {
    if (score >= 85) return success;
    if (score >= 70) return warning;
    return error;
  }

  /// Difficulty-based color, used on topic cards.
  static Color forDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return success;
      case 'Hard':
        return error;
      case 'Custom':
        return info;
      default:
        return Colors.orange; // Medium
    }
  }
}
