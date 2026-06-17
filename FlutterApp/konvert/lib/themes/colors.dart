import 'package:flutter/material.dart';
import '../models/enums.dart';

class AppColors {
  // Primary Colors
  static const Color primaryLight = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1565C0);
  
  // Secondary Colors
  static const Color secondaryLight = Color(0xFFFF6B6B);
  static const Color secondaryDark = Color(0xFFD32F2F);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Surface Colors
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  
  // Error Colors
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFEF5350);
  
  // Success Colors
  static const Color successLight = Color(0xFF388E3C);
  static const Color successDark = Color(0xFF66BB6A);
  
  // Warning Colors
  static const Color warningLight = Color(0xFFF57C00);
  static const Color warningDark = Color(0xFFFFA726);
  
  // Get color based on theme mode
  static Color getColor(Color lightColor, Color darkColor, ThemeModeVariations mode) {
    switch (mode) {
      case ThemeModeVariations.lightMode:
        return lightColor;
      case ThemeModeVariations.darkMode:
        return darkColor;
      case ThemeModeVariations.none:
      default:
        return lightColor; // Default to light mode
    }
  }
}