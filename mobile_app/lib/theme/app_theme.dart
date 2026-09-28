import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF046A38);
  static const Color darkGreen = Color(0xFF024424);
  static const Color accentSaffron = Color(0xFFFF671F);
  static const Color nationalNavy = Color(0xFF06038D);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static const Color statusSuccessBg = Color(0xFFDCFCE7);
  static const Color statusSuccessText = Color(0xFF166534);
  static const Color statusWarningBg = Color(0xFFFEF3C7);
  static const Color statusWarningText = Color(0xFF92400E);
  static const Color statusInfoBg = Color(0xFFDBEAFE);
  static const Color statusInfoText = Color(0xFF1E40AF);
  static const Color statusErrorBg = Color(0xFFFFE4E6);
  static const Color statusErrorText = Color(0xFF9F1239);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentSaffron,
        surface: Colors.white,
        background: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
    );
  }
}
