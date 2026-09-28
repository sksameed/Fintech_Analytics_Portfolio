// lib/theme.dart
// Design constants for CredLite.
// Centralizes colors, spacing, shadows, and typography to maintain a consistent
// CRED-inspired dark neumorphic aesthetic and eliminate magic numbers across the app.

import 'package:flutter/material.dart';

class AppTheme {
  // Brand & Background Colors
  static const Color background = Color(0xFF0F1115);
  static const Color surface = Color(0xFF171A21);
  static const Color surfaceElevated = Color(0xFF20242E);
  static const Color border = Color(0xFF282D3A);

  // Accent & Action Colors
  static const Color primary = Color(0xFF00E5FF); // Neon cyan highlight
  static const Color secondary = Color(0xFFFF3366); // Coral pink accent
  static const Color success = Color(0xFF00E676); // Bill paid / cash reward
  static const Color warning = Color(0xFFFFB300); // Due date approaching

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF616161);

  // 8-point Spacing Grid
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;

  // Corner Radii
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;

  // Soft Neumorphic Dual Shadows (light on top-left, dark on bottom-right)
  static const List<BoxShadow> softShadows = [
    BoxShadow(
      color: Color(0x66000000),
      offset: Offset(4, 5),
      blurRadius: 10,
    ),
    BoxShadow(
      color: Color(0x0DFFFFFF),
      offset: Offset(-3, -3),
      blurRadius: 7,
    ),
  ];

  // Elevated Shadows for Floating Cards
  static const List<BoxShadow> cardShadows = [
    BoxShadow(
      color: Color(0x99000000),
      offset: Offset(0, 10),
      blurRadius: 20,
    ),
    BoxShadow(
      color: Color(0x1A00E5FF),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  // Typography Styles
  static const String fontFamily = 'Inter';

  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );

  static const TextStyle amountLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  // App Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingMedium,
      ),
    );
  }
}
