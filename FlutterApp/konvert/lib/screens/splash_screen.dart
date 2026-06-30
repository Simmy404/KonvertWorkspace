// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../utils/page_transitions.dart';
import '../managers/legal_manager.dart';
import '../managers/theme_manager.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoFinished = false;
  bool _isImagesPreloaded = false;

  final double videoExitPoint = 85 / 100; // end video when 85% finished

  @override
  void initState() {
    super.initState();

    // Automatically resolves to 'assets/splash/konvert_splash_light.mp4' or '_dark.mp4'
    _controller = VideoPlayerController.asset(
      ThemeManager.instance.getSplashScreen(),
    );

    _initializeVideoAndAssets();
  }

  Future<void> _initializeVideoAndAssets() async {
    // 1. Initialize video controller
    await _controller.initialize();
    if (!mounted) return;

    setState(() {});
    _controller.play();
    _controller.setVolume(0);
    _controller.addListener(_checkVideoEnd);

    // 2. Start loading images in the background (Notice we don't 'await' this here
    // so the video isn't blocked from playing while images download)
    _preloadImages();
  }

  /// Downloads and caches 5 example images into memory
  Future<void> _preloadImages() async {
    try {
      // 5 Example network images (Replace with your actual AssetImage or NetworkImage paths)
      final List<ImageProvider> imagesToLoad = ThemeManager.instance
          .getImagesToPreload();

      // Use Future.wait to load all 5 images concurrently to save time
      await Future.wait(
        imagesToLoad.map((image) => precacheImage(image, context)),
      );

      debugPrint('All 5 background images preloaded successfully.');
    } catch (e) {
      debugPrint('Error preloading images: $e');
    } finally {
      // Whether it succeeded or failed, flag as done so the user isn't stuck
      // on the splash screen forever if a network request fails.
      if (mounted) {
        _isImagesPreloaded = true;
        _checkNavigationReady();
      }
    }
  }

  bool canBypassOnboarding() {
    return LegalManager.instance.hasAcceptedTerms;
  }

  void _checkVideoEnd() {
    if (_controller.value.isInitialized &&
        _controller.value.position >=
            (_controller.value.duration * videoExitPoint)) {
      _controller.removeListener(_checkVideoEnd);
      _isVideoFinished = true;
      _checkNavigationReady();
    }
  }

  // Ensures BOTH conditions are met before jumping to the onboarding route
  void _checkNavigationReady() {
    if (_isVideoFinished && _isImagesPreloaded && mounted) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    Widget nextScreen;

    if (!canBypassOnboarding()) {
      nextScreen = const WelcomeScreen();
    } else {
      // Temporary placeholder until you build your dashboard/home screen
      nextScreen = const Scaffold(body: Center(child: Text('Home Screen')));
    }

    // Uses your custom utility class for a clean, professional fade transition
    Navigator.pushReplacement(
      context,
      PageTransitions.fadeTransition(nextScreen),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_checkVideoEnd);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: _controller.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
