// lib/screens/theme_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../managers/theme_manager.dart';
import '../models/enums.dart';
// Add these imports at the top
import '../utils/page_transitions.dart';
import 'domain_screen.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  // Track the currently selected theme from the manager
  late Themes _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = ThemeManager.instance.currentTheme;
  }

  // Real-time refresh logic
  Future<void> _onThemeChanged(Themes newTheme) async {
    // 1. Save to local storage via ThemeManager
    await ThemeManager.instance.setThemeStyle(newTheme);

    // 2. Trigger a UI rebuild. Because all UI elements fetch their colors
    // dynamically from ThemeManager.instance in the build method, this will
    // instantly swap out backgrounds, text colors, etc.
    setState(() {
      _selectedTheme = newTheme;
    });
  }

  // Update this function inside _ThemeSelectionScreenState
  Future<void> _onConfirm() async {
    await ThemeManager.instance.setThemeStyle(_selectedTheme);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageTransitions.fadeSlideUpTransition(const DomainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the system default styling for the Default button
    final bool isSystemLight =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    final String defaultBgImage = isSystemLight
        ? 'assets/buttons/bg_accent.png'
        : 'assets/buttons/bg_neon.png';
    final Color defaultTextColor = isSystemLight ? Colors.black : Colors.white;
    final String defaultIconPath = isSystemLight
        ? 'assets/icons/ico_theme_default_accent.png'
        : 'assets/icons/ico_theme_default_neon.png';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      backgroundColor: Colors.black, // Fallback background
      body: Stack(
        children: [
          // Dynamic Background Layer
          Positioned.fill(
            child: Image.asset(
              ThemeManager.instance.getMainBG(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Colors.black),
            ),
          ),

          // Foreground UI Layer
          SafeArea(
            child: Padding(
              // MATCHED: Exact padding from Welcome and TOS screens
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16), // MATCHED: Exact top spacing
                  // MATCHED: Exact logo dimensions
                  Image.asset(
                    ThemeManager.instance.getLogoMark(),
                    width: 42,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Headers
                  Text(
                    'Select Theme',
                    style: TextStyle(
                      color: ThemeManager.instance.getPrimaryColor(),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A fresh look starts here. Pick your\nfavorite theme.',
                    style: TextStyle(
                      color: ThemeManager.instance.getGreyTransparent5(),
                      fontSize: 16,
                      height: 1.4,
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 0),

                  // Central Image replacing the white placeholder container
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        ThemeManager.instance.getThemeMain(),
                        fit: BoxFit
                            .contain, // This guarantees the aspect ratio remains perfectly intact
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 64,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Theme Selection Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildThemeCard(
                        theme: Themes.accent,
                        label: 'Accent',
                        iconPath: 'assets/icons/ico_theme_accent.png',
                        bgImagePath: 'assets/buttons/bg_accent.png',
                        textColor: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeCard(
                        theme: Themes.neon,
                        label: 'Neon',
                        iconPath: 'assets/icons/ico_theme_neon.png',
                        bgImagePath: 'assets/buttons/bg_neon.png',
                        textColor: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      _buildThemeCard(
                        theme: Themes.system,
                        label: 'Default',
                        iconPath: defaultIconPath,
                        bgImagePath: defaultBgImage,
                        textColor: defaultTextColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 64, // MATCHED: Exact button height
                    child: ElevatedButton(
                      onPressed: _onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeManager.instance
                            .getPrimaryColor(),
                        foregroundColor: ThemeManager.instance
                            .getContrastColor(),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  // Helper widget to construct the square theme buttons
  Widget _buildThemeCard({
    required Themes theme,
    required String label,
    required String iconPath,
    required String bgImagePath,
    required Color textColor,
  }) {
    final isSelected = _selectedTheme == theme;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onThemeChanged(theme),
        child: AspectRatio(
          aspectRatio: 1.0, // Forces the widget to be a perfect square
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Dynamic border highlights the active selection
              border: Border.all(
                color: isSelected
                    ? const Color(
                        0xFF4A4AFF,
                      ) // Adjust to match the blue outline in the design
                    : Colors.transparent,
                width: 2.5,
              ),
              image: DecorationImage(
                image: AssetImage(bgImagePath),
                fit: BoxFit.cover,
                // Fallback rendering if the button backgrounds aren't added to pubspec yet
                onError: (exception, stackTrace) =>
                    debugPrint('Missing asset: $bgImagePath'),
              ),
              // Fallback background color if the image fails to load
              color: const Color(0xFF1E1E1E),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Replaced the Icon widget with Image.asset to prevent tinting
                Image.asset(
                  iconPath,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.broken_image,
                    color: isSelected ? textColor : textColor.withOpacity(0.6),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? textColor : textColor.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
