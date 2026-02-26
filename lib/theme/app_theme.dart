import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color primaryTealLight = Color(0xFF14B8A6);
  
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  
  static const Color textMain = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  
  static const Color statusOnline = Colors.green;
  static const Color statusWarning = Colors.orange;
  static const Color statusError = Colors.red;
  static const Color statusOffline = Colors.grey;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: primaryTealLight,
        background: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textMain),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderLight),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 24),
        titleLarge: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 18),
        bodyLarge: TextStyle(color: textMain, fontSize: 16),
        bodyMedium: TextStyle(color: textMuted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
