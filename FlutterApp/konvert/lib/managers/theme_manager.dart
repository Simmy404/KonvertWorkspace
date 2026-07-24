// lib/managers/theme_manager.dart
import 'dart:ui'; // Required for PlatformDispatcher
import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';

class ThemeManager extends ChangeNotifier with WidgetsBindingObserver {
  ThemeManager._internal();
  static final ThemeManager instance = ThemeManager._internal();

  static const String _currentThemeKey = 'selected_theme_style';

  // Constants
  final String splashScreenDark = 'assets/splash/konvert_splash_dark.mp4';
  final String splashScreenLight = 'assets/splash/konvert_splash_light.mp4';

  final String welcomeBGDark = 'assets/backgrounds/welcomeBGDark.mp4';
  final String welcomeBGLight = 'assets/backgrounds/welcomeBGLight.mp4';

  final String logoMarkDark = 'assets/branding/Logomark_White.png';
  final String logoMarkLight = 'assets/branding/Logomark_Color.png';

  final String errorBGDark = 'assets/backgrounds/errorBGDark.png';
  final String errorBGLight = 'assets/backgrounds/errorBGLight.png';

  final String mainBGDark = 'assets/backgrounds/mainDark.png';
  final String mainBGLight = 'assets/backgrounds/mainLight.png';

  final String themeMainDark = 'assets/extras/themeMainDark.png';
  final String themeMainLight = 'assets/extras/themeMainLight.png';

  final String domainMainDark = 'assets/extras/domainMainDark.png';
  final String domainMainLight = 'assets/extras/domainMainLight.png';

  final String loginMainDark = 'assets/extras/loginMainDark.png';
  final String loginMainLight = 'assets/extras/loginMainLight.png';

  final String syncMainDark = 'assets/extras/syncMainDark.png';
  final String syncMainLight = 'assets/extras/syncMainLight.png';

  final String lockMainDark = 'assets/extras/lockMainDark.png';
  final String lockMainLight = 'assets/extras/lockMainLight.png';

  final Color contrastColorDark = const Color.fromARGB(255, 0, 0, 0);
  final Color contrastColorLight = const Color.fromARGB(255, 255, 255, 255);

  final Color matchColorDark = const Color.fromARGB(255, 255, 255, 255);
  final Color matchColorLight = const Color.fromARGB(255, 0, 0, 0);

  final Color primaryColorDark = const Color.fromARGB(255, 255, 255, 255);
  final Color primaryColorLight = const Color.fromARGB(255, 0, 0, 255);

  final Color greyTransparent1Dark = const Color.fromRGBO(255, 255, 255, 0.12);
  final Color greyTransparent1Light = const Color.fromRGBO(0, 0, 0, 0.12);

  final Color greyTransparent2Dark = const Color.fromARGB(120, 255, 255, 255);
  final Color greyTransparent2Light = const Color.fromARGB(120, 0, 0, 0);

  final Color greyTransparent3Dark = const Color.fromRGBO(255, 255, 255, 0.25);
  final Color greyTransparent3Light = const Color.fromRGBO(217, 217, 217, 0.25);

  final Color greyTransparent4Dark = const Color.fromRGBO(101, 101, 101, 0.25);
  final Color greyTransparent4Light = const Color.fromRGBO(233, 233, 233, 0.25);

  final Color greyTransparent5Dark = const Color.fromRGBO(255, 255, 255, 0.8);
  final Color greyTransparent5Light = const Color.fromRGBO(0, 0, 0, 0.8);

  final Color greyTransparent6Dark = const Color.fromRGBO(255, 255, 255, 0.12);
  final Color greyTransparent6Light = const Color.fromRGBO(0, 0, 0, 0.12);

  final String darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8ec3b9"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1a3646"}]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#4b687a"}]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#64779e"}]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#4b687a"}]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#334e68"}]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [{"color": "#021019"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#283d6a"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6f9ba5"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#023e58"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#3C7680"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#304a7d"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#98a5be"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#2c4568"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#1f2835"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#b0d5ce"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#98a5be"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#283d6a"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [{"color": "#3a4762"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#0e1626"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#4e6d96"}]
  }
]
''';

  Themes _currentTheme = Themes.accent;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    final savedThemeName = StorageService.instance.getString(_currentThemeKey);

    if (savedThemeName != null) {
      _currentTheme = Themes.values.firstWhere(
        (e) => e.name == savedThemeName,
        orElse: () => Themes.accent,
      );
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (_currentTheme == Themes.system) {
      notifyListeners();
    }
  }

  Themes get currentTheme => _currentTheme;

  bool get isLightMode => _isLightMode;

  // --- NEW LOGIC: Determine actual visual mode ---
  bool get _isLightMode {
    if (_currentTheme == Themes.accent) return true;
    if (_currentTheme == Themes.neon) return false;

    // If Themes.system, read directly from the device's hardware display settings
    return PlatformDispatcher.instance.platformBrightness == Brightness.light;
  }

  // --- UPDATED GETTERS: Route colors based on _isLightMode ---
  String getSplashScreen() =>
      _isLightMode ? splashScreenLight : splashScreenDark;
  String getWelcomeBG() => _isLightMode ? welcomeBGLight : welcomeBGDark;
  String getLogoMark() => _isLightMode ? logoMarkLight : logoMarkDark;
  String getErrorBG() => _isLightMode ? errorBGLight : errorBGDark;
  String getMainBG() => _isLightMode ? mainBGLight : mainBGDark;
  String getThemeMain() => _isLightMode ? themeMainLight : themeMainDark;
  String getDomainMain() => _isLightMode ? domainMainLight : domainMainDark;
  String getLoginMain() => _isLightMode ? loginMainLight : loginMainDark;
  String getSyncMain() => _isLightMode ? syncMainLight : syncMainDark;
  String getLockMain() => _isLightMode ? lockMainLight : lockMainDark;

  Color getContrastColor() =>
      _isLightMode ? contrastColorLight : contrastColorDark;
  Color getMatchColor() => _isLightMode ? matchColorLight : matchColorDark;
  Color getPrimaryColor() =>
      _isLightMode ? primaryColorLight : primaryColorDark;

  Color getGreyTransparent1() =>
      _isLightMode ? greyTransparent1Light : greyTransparent1Dark;
  Color getGreyTransparent2() =>
      _isLightMode ? greyTransparent2Light : greyTransparent2Dark;
  Color getGreyTransparent3() =>
      _isLightMode ? greyTransparent3Light : greyTransparent3Dark;
  Color getGreyTransparent4() =>
      _isLightMode ? greyTransparent4Light : greyTransparent4Dark;
  Color getGreyTransparent5() =>
      _isLightMode ? greyTransparent5Light : greyTransparent5Dark;
  Color getGreyTransparent6() =>
      _isLightMode ? greyTransparent6Light : greyTransparent6Dark;

  List<ImageProvider> getImagesToPreload() => [
    AssetImage(getLogoMark()),
    AssetImage(getErrorBG()),
    AssetImage(getMainBG()),
    AssetImage(getThemeMain()),
    AssetImage(getSyncMain()),
    AssetImage(getDomainMain()),
    AssetImage(getLoginMain()),
    AssetImage(getLockMain()),
  ];

  bool get hasSelectedTheme {
    return (StorageService.instance.getBool('has_selected_theme') ?? false) ||
        (StorageService.instance.getString(_currentThemeKey) != null);
  }

  Future<void> setThemeStyle(Themes style) async {
    _currentTheme = style;
    await StorageService.instance.setString(_currentThemeKey, style.name);
    await StorageService.instance.setBool('has_selected_theme', true);
    notifyListeners();
  }
}
