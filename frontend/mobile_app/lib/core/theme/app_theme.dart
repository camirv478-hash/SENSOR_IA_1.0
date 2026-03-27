import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg        = Color(0xFF021E16);
  static const Color surface   = Color(0xFF0A2E20);
  static const Color accent    = Colors.greenAccent;
  static const Color textLight = Colors.white;
  static const Color textMuted = Colors.white70;

  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: Colors.greenAccent,
      surface: surface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.green.withOpacity(0.1),
      hintStyle: const TextStyle(color: Colors.white54),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}