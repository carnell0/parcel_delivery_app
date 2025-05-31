import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primaryColor: const Color(0xFFF28C38),
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1C2526)),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF616161)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF28C38),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFF28C38), width: 2),
    ),
  ),
);