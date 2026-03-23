import 'package:flutter/material.dart';

class AppTheme {
  // Monochrome & Product-specific tones
  static const Color accentWhite = Color(0xFFFFFFFF);
  static const Color accentDark = Color(0xFF1D1D1F); // Space Grey
  
  static const Color backgroundLight = Color(0xFF000000); // Black
  static const Color highlightGrey = Color(0xFF1D1D1F); // Space Grey
  static const Color borderLight = Color(0xFF38383A); 
  
  static const Color textMain = Color(0xFFFFFFFF); // White
  static const Color textMuted = Color(0xFF8E8E93); 
  
  static const Color statusOnline = Colors.green;
  static const Color statusWarning = Colors.orange;
  static const Color statusError = Colors.red;
  static const Color statusOffline = Colors.grey;

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: '.SF Pro Text',
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: highlightGrey,
        primary: accentWhite,
        secondary: highlightGrey,
        background: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      highlightColor: highlightGrey,
      splashColor: highlightGrey,
      hoverColor: highlightGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: '.SF Pro Text', // Primary
        ),
        iconTheme: IconThemeData(color: textMain),
      ),
      cardTheme: CardThemeData(
        color: highlightGrey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none, // Cleaner, spacious borderless cards
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textMain, fontWeight: FontWeight.w700, fontSize: 28, fontFamily: '.SF Pro Display', letterSpacing: -0.5), // Professional dashboard header
        headlineMedium: TextStyle(color: textMain, fontWeight: FontWeight.w600, fontSize: 20, fontFamily: '.SF Pro Text', letterSpacing: -0.2), 
        titleLarge: TextStyle(color: textMain, fontWeight: FontWeight.w600, fontSize: 16, fontFamily: '.SF Pro Text'),
        bodyLarge: TextStyle(color: textMain, fontSize: 14, fontFamily: '.SF Pro Text', height: 1.4),
        bodyMedium: TextStyle(color: textMuted, fontSize: 12, fontFamily: '.SF Pro Text', height: 1.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentWhite,
          foregroundColor: backgroundLight, // Black text on white structural button
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Dense layout
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // Technical square layout
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text', fontSize: 14),
        ),
      ),
    );
  }
}
