// lib/screens/welcome_screen.dart
import 'package:Konvert/managers/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late VideoPlayerController _bgController;
  bool _isBgInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeBackgroundVideo();
  }

  Future<void> _initializeBackgroundVideo() async {
    _bgController = VideoPlayerController.asset(
      ThemeManager.instance.getWelcomeBG(),
    );

    try {
      await _bgController.initialize();
      if (!mounted) return;

      setState(() {
        _isBgInitialized = true;
      });

      // Configure background video behavior
      _bgController.play();
      _bgController.setLooping(true);
      _bgController.setVolume(0); // Ensure ambient video is completely silent
    } catch (e) {
      debugPrint('Error initializing welcome background video: $e');
    }
  }

  Future<void> _launchHelpUrl() async {
    final Uri url = Uri.parse('https://example.com/support');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch target URL: $url');
      }
    } catch (e) {
      debugPrint('Error attempting to launch URL: $e');
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.instance
          .getContrastColor(), // Fallback color while video initializes
      body: Stack(
        children: [
          // 1. Background Layer (Video)
          if (_isBgInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _bgController.value.size.width,
                  height: _bgController.value.size.height,
                  child: VideoPlayer(_bgController),
                ),
              ),
            ),

          // 2. Foreground Layer (UI Elements)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  Image.asset(
                    ThemeManager.instance.getLogoMark(),
                    width: 42,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 32,
                      );
                    },
                  ),

                  const Spacer(),

                  Text(
                    'Keep Your\nSales Moving',
                    style: TextStyle(
                      color: ThemeManager.instance.getMatchColor(),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),

                  const SizedBox(height: 10),

                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: ThemeManager.instance.getMatchColor(),
                        fontSize: 16,
                        height: 1.4,
                        letterSpacing: -0.2,
                      ),
                      children: const [
                        TextSpan(
                          text:
                              'Track sales, manage teams, and generate\ninsights from anywhere.\n',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        // Action handler pipeline
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeManager.instance
                            .getPrimaryColor(),
                        foregroundColor: ThemeManager.instance
                            .getContrastColor(),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: _launchHelpUrl,
                      style: TextButton.styleFrom(
                        foregroundColor: ThemeManager.instance.getMatchColor(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      child: const Text(
                        'Need Help?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
