// lib/managers/theme_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import 'package:flutter/material.dart';

class ThemeManager {
  // Private constructor for Singleton pattern
  ThemeManager._internal();

  // The single, shared instance of this class
  static final ThemeManager instance = ThemeManager._internal();

  SharedPreferences? _prefs;

  // Storage Key for the active theme
  static const String _currentThemeKey = 'selected_theme_style';

  // Constant asset paths requested
  final String splashScreenDark = 'assets/splash/konvert_splash_dark.mp4';
  final String splashScreenLight = 'assets/splash/konvert_splash_light.mp4';

  final String welcomeBGDark = 'assets/backgrounds/welcomeBGDark.mp4';
  final String welcomeBGLight = 'assets/backgrounds/welcomeBGLight.mp4';

  final String logoMarkDark = 'assets/branding/Logomark_White.png';
  final String logoMarkLight = 'assets/branding/Logomark_Color.png';

  final Color contrastColorDark = Color.fromARGB(255, 0, 0, 0);
  final Color contrastColorLight = Color.fromARGB(255, 255, 255, 255);

  final Color matchColorDark = Color.fromARGB(255, 255, 255, 255);
  final Color matchColorLight = Color.fromARGB(255, 0, 0, 0);

  final Color primaryColorDark = Color.fromARGB(255, 255, 255, 255);
  final Color primaryColorLight = Color.fromARGB(255, 0, 0, 255);

  // State fields: Defaulting completely to light mode (Themes.accent)
  Themes _currentTheme = Themes.accent;

  /// Initializes SharedPreferences and restores saved theme state.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Read the stored theme name directly string-by-string to support multi-theme scaling
    final savedThemeName = _prefs?.getString(_currentThemeKey);
    if (savedThemeName != null) {
      _currentTheme = Themes.values.firstWhere(
        (e) => e.name == savedThemeName,
        orElse: () => Themes.accent,
      );
    }
  }

  List<ImageProvider> getImagesToPreload() {
    final List<ImageProvider> imagesToLoad = [
      NetworkImage(getSplashScreen()),
      NetworkImage(getWelcomeBG()),
    ];
    return imagesToLoad;
  }

  // Getter to check the active theme state externally
  Themes get currentTheme => _currentTheme;

  /// Returns the correct splash screen asset string based on the current theme enum.
  String getSplashScreen() {
    if (_currentTheme == Themes.accent) {
      return splashScreenLight;
    } else {
      return splashScreenDark; // Used for Themes.neon or other darker themes
    }
  }

  String getWelcomeBG() {
    if (_currentTheme == Themes.accent) {
      return welcomeBGLight;
    } else {
      return welcomeBGDark; // Used for Themes.neon or other darker themes
    }
  }

  String getLogoMark() {
    if (_currentTheme == Themes.accent) {
      return logoMarkLight;
    } else {
      return logoMarkDark; // Used for Themes.neon or other darker themes
    }
  }

  Color getContrastColor() {
    if (_currentTheme == Themes.accent) {
      return contrastColorLight;
    } else {
      return contrastColorDark; // Used for Themes.neon or other darker themes
    }
  }

  Color getMatchColor() {
    if (_currentTheme == Themes.accent) {
      return matchColorLight;
    } else {
      return matchColorDark; // Used for Themes.neon or other darker themes
    }
  }

  Color getPrimaryColor() {
    if (_currentTheme == Themes.accent) {
      return primaryColorLight;
    } else {
      return primaryColorDark; // Used for Themes.neon or other darker themes
    }
  }

  /// Updates and stores the active App Theme style type dynamically.
  Future<void> setThemeStyle(Themes style) async {
    _currentTheme = style;
    // Persisting as a string value allows you to change the Enum index order later
    // without scrambling users' local data cache.
    await _prefs?.setString(_currentThemeKey, style.name);
  }
}
