// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../utils/page_transitions.dart';
import '../managers/legal_manager.dart';
import '../managers/theme_manager.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart';
import '../services/storage_service.dart';
import 'welcome_screen.dart';
import 'theme_selection_screen.dart';
import 'dashboard_screen.dart';
import 'domain_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoFinished = false;
  bool _isImagesPreloaded = false;

  final double videoExitPoint = 85 / 100;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      ThemeManager.instance.getSplashScreen(), 
    );
    _initializeVideoAndAssets();
  }

  Future<void> _initializeVideoAndAssets() async {
    try {
      await _controller.initialize();
      if (!mounted) return;

      setState(() {});
      _controller.play(); 
      _controller.setVolume(0); 
      _controller.addListener(_checkVideoEnd); 
    } catch (e) {
      // Major failure: Splash video engine crashed
      ErrorManager.instance.showCriticalErrorScreen(
        ErrorStruct(
          code: 'SPL-001',
          technicalDetails: 'Splash video engine failed to initialize: $e'
        )
      );
      return; 
    }

    _preloadImages(); 
  }

  Future<void> _preloadImages() async {
    try {
      final List<ImageProvider> imagesToLoad = ThemeManager.instance.getImagesToPreload(); 
      await Future.wait(
        imagesToLoad.map((image) => precacheImage(image, context).catchError((_) => true)),
      );
    } catch (e) {
      // Minor failure: Images didn't cache. Non-blocking, just show toast.
      ErrorManager.instance.showToastError(
        ErrorStruct(
          code: 'SPL-002',
          technicalDetails: 'Assets failed to preload: $e'
        ),
        3
      );
    } finally {
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
        _controller.value.position >= (_controller.value.duration * videoExitPoint)) { 
      _controller.removeListener(_checkVideoEnd); 
      _isVideoFinished = true; 
      _checkNavigationReady(); 
    }
  }

  void _checkNavigationReady() {
    if (_isVideoFinished && _isImagesPreloaded && mounted) { 
      _navigateToNextScreen();
    }
  }

  Future<void> _navigateToNextScreen() async {
    _controller.removeListener(_checkVideoEnd);
    _controller.pause();

    final currentUser = StorageService.instance.getCurrentUser();
    final currentCompany = StorageService.instance.getCurrentCompany();
    final hasSelectedTheme = ThemeManager.instance.hasSelectedTheme;
    final hasAcceptedTerms = LegalManager.instance.hasAcceptedTerms;

    Widget nextScreen;
    if (currentUser != null && currentCompany != null) {
      nextScreen = const DashboardScreen(fromLogin: false);
    } else if (currentCompany != null) {
      nextScreen = const LoginScreen();
    } else if (hasSelectedTheme) {
      nextScreen = const DomainScreen();
    } else if (hasAcceptedTerms) {
      nextScreen = const ThemeSelectionScreen();
    } else {
      final welcomeVideoController = VideoPlayerController.asset(
        ThemeManager.instance.getWelcomeBG(),
      );

      try {
        await welcomeVideoController.initialize();
        welcomeVideoController.play();
        welcomeVideoController.setLooping(true);
        welcomeVideoController.setVolume(0);
      } catch (e) {
        // Major failure: Transition pipeline crashed
        ErrorManager.instance.showCriticalErrorScreen(
          ErrorStruct(
            code: 'SPL-003',
            technicalDetails: 'Welcome transition video pipeline failed: $e'
          )
        );
        return;
      }

      if (!mounted) {
        welcomeVideoController.dispose();
        return;
      }

      Navigator.pushReplacement(
        context,
        PageTransitions.fadeTransition(WelcomeScreen(preinitializedController: welcomeVideoController)), 
      );
      return;
    }

    if (!mounted) return;

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