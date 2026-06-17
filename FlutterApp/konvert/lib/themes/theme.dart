// lib/themes/theme.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'colors.dart';
import '../models/enums.dart';
import '../managers/app_manager.dart';

class AppTheme {
  static ThemeData getTheme(AppManager appManager) {
    final themeMode = appManager.selectedTheme;
    
    // Determine if we should use dark mode
    final bool isDark = (themeMode == ThemeModeVariations.darkMode);
    
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      
      // Primary Color Scheme
      primaryColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      primaryColorLight: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      primaryColorDark: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      
      // Color Scheme
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: isDark ? AppColors.primaryDark : AppColors.primaryLight,
        onPrimary: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        secondary: isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
        onSecondary: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        error: isDark ? AppColors.errorDark : AppColors.errorLight,
        onError: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        background: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        onBackground: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primaryLight,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 4,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        displayMedium: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        displaySmall: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        headlineMedium: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        headlineSmall: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        titleLarge: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        bodyLarge: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        bodyMedium: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        bodySmall: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.errorDark : AppColors.errorLight,
          ),
        ),
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}

// Extension to easily get themed colors - Fixed version
extension ThemeColors on BuildContext {
  AppColors get colors => AppColors();
  
  bool get isDarkMode {
    // Use Provider to get the AppManager instance
    try {
      final appManager = Provider.of<AppManager>(this, listen: false);
      return appManager.selectedTheme == ThemeModeVariations.darkMode;
    } catch (e) {
      // If no provider found, default to light mode
      return false;
    }
  }
}