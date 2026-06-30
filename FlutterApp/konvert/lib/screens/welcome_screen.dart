// lib/screens/welcome_screen.dart
import 'package:Konvert/managers/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatefulWidget {
  // Accept the fully prepared controller directly from the splash transition thread
  final VideoPlayerController preinitializedController;

  const WelcomeScreen({
    super.key,
    required this.preinitializedController,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Directly point to the passed instance field
  late final VideoPlayerController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = widget.preinitializedController;
    
    // In case initialization was skipped due to exceptional fallback errors in splash screen
    if (!_bgController.value.isInitialized) {
      _retryWelcomeVideoInitialization();
    }
  }

  Future<void> _retryWelcomeVideoInitialization() async {
    try {
      await _bgController.initialize();
      if (!mounted) return;
      setState(() {});
      _bgController.play();
      _bgController.setLooping(true);
      _bgController.setVolume(0);
    } catch (e) {
      debugPrint('Fallback initialization retry failed: $e');
    }
  }

  Future<void> _launchHelpUrl() async {
    final Uri url = Uri.parse('https://example.com/support'); //[cite: 1]
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) { //[cite: 1]
        debugPrint('Could not launch target URL: $url'); //[cite: 1]
      }
    } catch (e) {
      debugPrint('Error attempting to launch URL: $e'); //[cite: 1]
    }
  }

  @override
  void dispose() {
    // Safely tear down the video pipeline when the user completes onboarding
    _bgController.dispose(); //[cite: 1]
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.instance.getContrastColor(), //[cite: 1]
      body: Stack(
        children: [
          // 1. Background Layer (Instantaneous video render without flash frames)
          if (_bgController.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover, //[cite: 1]
                child: SizedBox(
                  width: _bgController.value.size.width, //[cite: 1]
                  height: _bgController.value.size.height, //[cite: 1]
                  child: VideoPlayer(_bgController), //[cite: 1]
                ),
              ),
            ),

          // 2. Foreground Layer (UI Elements)[cite: 1]
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0), //[cite: 1]
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16), //[cite: 1]
                  Image.asset(
                    ThemeManager.instance.getLogoMark(), //[cite: 1]
                    width: 42, //[cite: 1]
                    height: 32, //[cite: 1]
                    fit: BoxFit.contain, //[cite: 1]
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: Colors.white, size: 32); //[cite: 1]
                    },
                  ),
                  const Spacer(), //[cite: 1]
                  Text(
                    'Keep Your\nSales Moving',
                    style: TextStyle(
                      color: ThemeManager.instance.getMatchColor(), //[cite: 1]
                      fontSize: 48, //[cite: 1]
                      fontWeight: FontWeight.bold, //[cite: 1]
                      height: 1.1, //[cite: 1]
                      letterSpacing: -1.0, //[cite: 1]
                    ),
                  ),
                  const SizedBox(height: 10), //[cite: 1]
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: ThemeManager.instance.getMatchColor(), //[cite: 1]
                        fontSize: 16, //[cite: 1]
                        height: 1.4, //[cite: 1]
                        letterSpacing: -0.2, //[cite: 1]
                      ),
                      children: const [
                        TextSpan(text: 'Track sales, manage teams, and generate\ninsights from anywhere.\n'), //[cite: 1]
                      ],
                    ),
                  ),
                  const SizedBox(height: 48), //[cite: 1]
                  SizedBox(
                    width: double.infinity, //[cite: 1]
                    height: 64, //[cite: 1]
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeManager.instance.getPrimaryColor(), //[cite: 1]
                        foregroundColor: ThemeManager.instance.getContrastColor(), //[cite: 1]
                        shape: const StadiumBorder(), //[cite: 1]
                        elevation: 0, //[cite: 1]
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3), //[cite: 1]
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), //[cite: 1]
                  Center(
                    child: TextButton(
                      onPressed: _launchHelpUrl, //[cite: 1]
                      style: TextButton.styleFrom(
                        foregroundColor: ThemeManager.instance.getMatchColor(), //[cite: 1]
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), //[cite: 1]
                      ),
                      child: const Text(
                        'Need Help?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2), //[cite: 1]
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), //[cite: 1]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}