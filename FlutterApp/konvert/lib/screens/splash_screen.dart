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

  final double videoExitPoint = 85 / 100; // end video when 85% finished[cite: 3]

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      ThemeManager.instance.getSplashScreen(), //[cite: 3]
    );
    _initializeVideoAndAssets();
  }

  Future<void> _initializeVideoAndAssets() async {
    try {
      await _controller.initialize(); //[cite: 3]
      if (!mounted) return;

      setState(() {});
      _controller.play(); //[cite: 3]
      _controller.setVolume(0); //[cite: 3]
      _controller.addListener(_checkVideoEnd); //[cite: 3]
    } catch (e) {
      debugPrint('Error initializing splash video: $e');
      _isVideoFinished = true;
    }

    _preloadImages(); //[cite: 3]
  }

  Future<void> _preloadImages() async {
    try {
      final List<ImageProvider> imagesToLoad = ThemeManager.instance.getImagesToPreload(); //[cite: 3]
      await Future.wait(
        imagesToLoad.map((image) => precacheImage(image, context).catchError((_) => true)),
      );
      debugPrint('Splash images checked safely.');
    } catch (e) {
      debugPrint('Error preloading images: $e'); //[cite: 3]
    } finally {
      if (mounted) {
        _isImagesPreloaded = true; //[cite: 3]
        _checkNavigationReady(); //[cite: 3]
      }
    }
  }

  bool canBypassOnboarding() {
    return LegalManager.instance.hasAcceptedTerms; //[cite: 3]
  }

  void _checkVideoEnd() {
    if (_controller.value.isInitialized &&
        _controller.value.position >= (_controller.value.duration * videoExitPoint)) { //[cite: 3]
      _controller.removeListener(_checkVideoEnd); //[cite: 3]
      _isVideoFinished = true; //[cite: 3]
      _checkNavigationReady(); //[cite: 3]
    }
  }

  void _checkNavigationReady() {
    if (_isVideoFinished && _isImagesPreloaded && mounted) { //[cite: 3]
      _navigateToNextScreen();
    }
  }

  // Optimized pipeline handler to handle background preparation on the fly
  Future<void> _navigateToNextScreen() async {
    // Stop listening to splash updates to prevent double execution triggers
    _controller.removeListener(_checkVideoEnd);

    if (!canBypassOnboarding()) { //[cite: 3]
      // 1. We know onboarding is required. Create the next controller asset stream instance right here.
      final welcomeVideoController = VideoPlayerController.asset(
        ThemeManager.instance.getWelcomeBG(),
      );

      try {
        // 2. Await initialization BEFORE the page routing begins
        await welcomeVideoController.initialize();
        welcomeVideoController.play();
        welcomeVideoController.setLooping(true);
        welcomeVideoController.setVolume(0);
      } catch (e) {
        debugPrint('Failed to warm up welcome video controller in transition: $e');
      }

      if (!mounted) {
        welcomeVideoController.dispose();
        return;
      }

      // Stop the splash video loop instantly to cleanly free up device hardware decoder layers
      _controller.pause();

      // 3. Hand off the completely warmed-up video player to the welcome viewport
      Navigator.pushReplacement(
        context,
        PageTransitions.fadeTransition(WelcomeScreen(preinitializedController: welcomeVideoController)), //[cite: 3]
      );
    } else {
      _controller.pause();
      Navigator.pushReplacement(
        context,
        PageTransitions.fadeTransition(const Scaffold(body: Center(child: Text('Home Screen')))), //[cite: 3]
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_checkVideoEnd); //[cite: 3]
    _controller.dispose(); //[cite: 3]
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black, //[cite: 3]
        child: Center(
          child: _controller.value.isInitialized //[cite: 3]
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover, //[cite: 3]
                    child: SizedBox(
                      width: _controller.value.size.width, //[cite: 3]
                      height: _controller.value.size.height, //[cite: 3]
                      child: VideoPlayer(_controller), //[cite: 3]
                    ),
                  ),
                )
              : const CircularProgressIndicator(color: Colors.white), //[cite: 3]
        ),
      ),
    );
  }
}