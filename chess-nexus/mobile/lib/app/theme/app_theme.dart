import 'package:flutter/material.dart';

class NexusColors {
  // Locked Creative Decision Palette
  static const Color obsidian = Color(0xFF080B0A);
  static const Color deepForest = Color(0xFF111A16);
  static const Color emerald = Color(0xFF19382B);
  static const Color mintAccent = Color(0xFFA6D6B5);
  static const Color champagne = Color(0xFFC6A66B);
  static const Color ivory = Color(0xFFEAE8DF);
  static const Color secondaryText = Color(0xFF9CA99F);

  // Status & Tactical Colors
  static const Color danger = Color(0xFFE05353);
  static const Color success = Color(0xFF38C172);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);

  // Board Specific Shades
  static const Color boardDark = Color(0xFF19382B);
  static const Color boardLight = Color(0xFFEAE8DF);
  static const Color moveHighlight = Color(0x66A6D6B5);
  static const Color checkGlow = Color(0x99E05353);
  static const Color threatOutline = Color(0x88E05353);
}

class NexusTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NexusColors.obsidian,
      primaryColor: NexusColors.emerald,
      colorScheme: const ColorScheme.dark(
        primary: NexusColors.mintAccent,
        secondary: NexusColors.champagne,
        surface: NexusColors.deepForest,
        background: NexusColors.obsidian,
        error: NexusColors.danger,
        onPrimary: NexusColors.obsidian,
        onSecondary: NexusColors.obsidian,
        onSurface: NexusColors.ivory,
        onBackground: NexusColors.ivory,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NexusColors.obsidian,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: NexusColors.ivory),
        titleTextStyle: TextStyle(
          color: NexusColors.ivory,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NexusColors.deepForest,
        selectedItemColor: NexusColors.mintAccent,
        unselectedItemColor: NexusColors.secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardTheme(
        color: NexusColors.deepForest,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x3319382B), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NexusColors.emerald,
          foregroundColor: NexusColors.ivory,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NexusColors.mintAccent,
          side: const BorderSide(color: NexusColors.mintAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

