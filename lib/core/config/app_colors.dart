import 'package:flutter/material.dart';

/// MifugoCare Color Palette
/// Modern, clean design with white backgrounds and bright green accents
class AppColors {
  AppColors._();

  // PRIMARY COLORS
  static const Color primary = Color(0xFF00C851); // Bright green
  static const Color primaryDark = Color(0xFF00A041);
  static const Color primaryLight = Color(0xFFE8F5E8);

  // SECONDARY COLORS
  static const Color secondary = Color(0xFF424242);
  static const Color secondaryLight = Color(0xFF757575);

  // BACKGROUND COLORS
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF2C2C2C);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // TEXT COLORS
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textWhite = Color(0xFFFFFFFF);

  // ACCENT COLORS
  static const Color accent = Color(0xFFFFC107); // Amber
  static const Color accentBlue = Color(0xFF1976D2);

  // STATUS COLORS
  static const Color success = Color(0xFF4CAF50);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color alertRed = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // FUNCTIONAL COLORS
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  static const Color overlayDark = Color(0xBF000000);

  // GRADIENTS
  static const LinearGradient darkToTransparent = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xBF000000),
      Color(0x00000000),
    ],
    stops: [0.0, 0.7],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  // HELPER METHODS
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 80) return successGreen;
    if (confidence >= 60) return warningOrange;
    return alertRed;
  }

  static Color getSeverityColor(int severity) {
    if (severity < 30) return successGreen;
    if (severity < 70) return warningOrange;
    return alertRed;
  }
}
