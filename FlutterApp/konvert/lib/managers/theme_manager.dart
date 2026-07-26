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

  final String dashboardMainDark = 'assets/extras/dashboardMainDark.png';
  final String dashboardMainLight = 'assets/extras/dashboardMainLight.png';

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

  // Place Order Button Colors
  final Color placeOrderTopDark = const Color(0xFF0059FF);
  final Color placeOrderBottomDark = const Color(0xFF210099);
  final Color placeOrderBorderDark = const Color(0xFFFFFFFF);

  final Color placeOrderTopLight = const Color(0xFF0E06FF);
  final Color placeOrderBottomLight = const Color(0xFF050094);
  final Color placeOrderBorderLight = const Color(0xFFFFFFFF);

  // Target Card Colors
  final Color targetCardTopDark = const Color(0xFF6A00FF);
  final Color targetCardBottomDark = const Color(0xFF000345);
  final Color targetCardValueDark = const Color(0xFFFFFFFF);
  final Color targetCardLabelDark = const Color(0xFF9AB7FF);

  final Color targetCardTopLight = const Color(0xFF00FFEA);
  final Color targetCardBottomLight = const Color(0x0000FFEA);
  final Color targetCardValueLight = const Color(0xFF000000);
  final Color targetCardLabelLight = const Color.fromARGB(255, 255, 255, 255);

  // Bottom Nav Bar Colors
  final Color navBarTopDark = const Color(0xFF003BFF).withValues(alpha: 0.58);
  final Color navBarBottomDark = const Color(0xFF0004FF).withValues(alpha: 0.0);
  final Color navBarBorderDark = const Color(0xFF8E61FF).withValues(alpha: 0.38);

  final Color navBarTopLight = const Color(0xFFFFFFFF);
  final Color navBarBottomLight = const Color(0xFFDBEAFF);
  final Color navBarBorderLight = const Color(0xFF97D4FF).withValues(alpha: 0.76);

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
    "stylers": [{"color": "#48628b"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#18253f"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#c5d5ea"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{"color": "#5070a0"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#60a5fa"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#1d3b6e"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#ffffff"}]
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
  String getDashboardMain() =>
      _isLightMode ? dashboardMainLight : dashboardMainDark;

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

  Color getPlaceOrderTopColor({bool? isDark}) {
    final useLight = isDark != null ? !isDark : _isLightMode;
    return useLight ? placeOrderTopLight : placeOrderTopDark;
  }

  Color getPlaceOrderBottomColor({bool? isDark}) {
    final useLight = isDark != null ? !isDark : _isLightMode;
    return useLight ? placeOrderBottomLight : placeOrderBottomDark;
  }

  Color getPlaceOrderBorderColor({bool? isDark}) {
    final useLight = isDark != null ? !isDark : _isLightMode;
    return useLight ? placeOrderBorderLight : placeOrderBorderDark;
  }

  LinearGradient getPlaceOrderGradient({bool? isDark}) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      getPlaceOrderTopColor(isDark: isDark),
      getPlaceOrderBottomColor(isDark: isDark),
    ],
  );

  Color getTargetCardTopColor({bool? isDark}) {
    final useLight = isDark != null ? !isDark : _isLightMode;
    return useLight ? targetCardTopLight : targetCardTopDark;
  }

  Color getTargetCardBottomColor({bool? isDark}) {
    final useLight = isDark != null ? !isDark : _isLightMode;
    return useLight ? targetCardBottomLight : targetCardBottomDark;
  }

  Color getTargetCardValueColor({bool? isDark}) {
    final useLight = isDark != null ? !isDark : _isLightMode;
    return useLight ? targetCardValueLight : targetCardValueDark;
  }

  Color getTargetCardLabelColor({bool? isDark}) {
    final useLight = isDark != null ? !isDark : _isLightMode;
    return useLight ? targetCardLabelLight : targetCardLabelDark;
  }

  LinearGradient getTargetCardGradient({bool? isDark}) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      getTargetCardTopColor(isDark: isDark),
      getTargetCardBottomColor(isDark: isDark),
    ],
  );

  Color getNavBarTopColor({bool? isDark}) {
    final useLight = isDark != null ? !isDark : _isLightMode;
    return useLight ? navBarTopLight : navBarTopDark;
  }

  Color getNavBarBottomColor({bool? isDark}) {
    final useLight = isDark != null ? !isDark : _isLightMode;
    return useLight ? navBarBottomLight : navBarBottomDark;
  }

  Color getNavBarBorderColor({bool? isDark}) {
    final useLight = isDark != null ? !isDark : _isLightMode;
    return useLight ? navBarBorderLight : navBarBorderDark;
  }

  LinearGradient getNavBarGradient({bool? isDark}) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      getNavBarTopColor(isDark: isDark),
      getNavBarBottomColor(isDark: isDark),
    ],
  );

  List<ImageProvider> getImagesToPreload() => [
    AssetImage(getLogoMark()),
    AssetImage(getErrorBG()),
    AssetImage(getMainBG()),
    AssetImage(getThemeMain()),
    AssetImage(getSyncMain()),
    AssetImage(getDomainMain()),
    AssetImage(getLoginMain()),
    AssetImage(getLockMain()),
    AssetImage(getDashboardMain()),
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

  // --- SEMANTIC COLORS ---

  // Backgrounds & Surfaces
  Color getAppBackgroundColor() => _isLightMode ? const Color(0xFFF8FAFC) : const Color(0xFF020414);
  Color getSurfaceColor() => _isLightMode ? const Color(0xFFF6F8FD) : const Color(0xFF111526);
  Color getContainerColor() => _isLightMode ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  Color getListItemColor() => _isLightMode ? const Color(0xFFF3F4F9) : const Color.fromARGB(80, 41, 51, 73);

  // Text Colors
  Color getTextPrimary() => _isLightMode ? const Color(0xFF0F172A) : Colors.white;
  Color getTextSecondary() => _isLightMode ? const Color(0xFF475569) : Colors.white70;
  Color getTextTertiary() => _isLightMode ? const Color(0xFF94A3B8) : Colors.white38;

  // Borders & Dividers
  Color getBorderColor() => _isLightMode ? const Color(0xFFD4DDF3) : const Color(0xFF2A324A);
  Color getDividerColor() => _isLightMode ? Colors.black12 : Colors.white24;

  // Brand & Accents
  Color getAccentBlue() => _isLightMode ? const Color(0xFF0022FF) : const Color(0xFF1E56E2);

}
