import '../models/enums.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeManager {
  ThemeManager._internal();
  static final ThemeManager instance = ThemeManager._internal();

  static const String _currentThemeKey = 'selected_theme_style';

  // (Keep all your existing color/asset constants here...)
  final String splashScreenDark = 'assets/splash/konvert_splash_dark.mp4';
  final String splashScreenLight = 'assets/splash/konvert_splash_light.mp4';

  final String welcomeBGDark = 'assets/backgrounds/welcomeBGDark.mp4';
  final String welcomeBGLight = 'assets/backgrounds/welcomeBGLight.mp4';

  final String logoMarkDark = 'assets/branding/Logomark_White.png';
  final String logoMarkLight = 'assets/branding/Logomark_Color.png';

  final String errorBGDark = 'assets/backgrounds/errorBGDark.png';
  final String errorBGLight = 'assets/backgrounds/errorBGLight.png';

  final Color contrastColorDark = Color.fromARGB(255, 0, 0, 0);
  final Color contrastColorLight = Color.fromARGB(255, 255, 255, 255);

  final Color matchColorDark = Color.fromARGB(255, 255, 255, 255);
  final Color matchColorLight = Color.fromARGB(255, 0, 0, 0);

  final Color primaryColorDark = Color.fromARGB(255, 255, 255, 255);
  final Color primaryColorLight = Color.fromARGB(255, 0, 0, 255);


  Themes _currentTheme = Themes.accent;

  Future<void> init() async {
    // Rely on StorageService instead of SharedPreferences directly
    final savedThemeName = StorageService.instance.getString(_currentThemeKey);
    
    if (savedThemeName != null) {
      _currentTheme = Themes.values.firstWhere(
        (e) => e.name == savedThemeName,
        
        orElse: () => Themes.accent,
      );
    }
  }

  // (Keep all your existing getters here...)
  Themes get currentTheme => _currentTheme;
  String getSplashScreen() => _currentTheme == Themes.accent ? splashScreenLight : splashScreenDark;
  String getWelcomeBG() => _currentTheme == Themes.accent ? welcomeBGLight : welcomeBGDark;
  String getLogoMark() => _currentTheme == Themes.accent ? logoMarkLight : logoMarkDark;
  String getErrorBG() => _currentTheme == Themes.accent ? errorBGLight : errorBGDark;
  Color getContrastColor() => _currentTheme == Themes.accent ? contrastColorLight : contrastColorDark;
  Color getMatchColor() => _currentTheme == Themes.accent ? matchColorLight : matchColorDark;
  Color getPrimaryColor() => _currentTheme == Themes.accent ? primaryColorLight : primaryColorDark;
  List<ImageProvider> getImagesToPreload() => [NetworkImage(getSplashScreen()), NetworkImage(getWelcomeBG())];

  Future<void> setThemeStyle(Themes style) async {
    _currentTheme = style;
    // Persist cleanly via the service layer
    await StorageService.instance.setString(_currentThemeKey, style.name);
  }
}