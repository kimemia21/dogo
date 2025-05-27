import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Color(0xFF3B82F6),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF3B82F6),
        secondary: Color(0xFF3B82F6),
        surface: Colors.white,
        background: Color(0xFFF1F5F9),
      ),
      fontFamily: 'Poppins',
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28, 
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
        headlineMedium: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF64748B),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}
