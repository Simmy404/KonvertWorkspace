// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../managers/app_manager.dart';
import '../utils/page_transitions.dart';
import 'welcome_screen.dart';
import 'dashboard_screen.dart';
import 'terms_of_service_screen.dart';
import 'domain_selection_screen.dart';
import 'user_type_selection_screen.dart';
import 'business_hierarchy_screen.dart';
import 'sales_rep_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/splash/konvert_splash.mp4',
    );
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await _controller.initialize();
    if (!mounted) return;
    setState(() {});
    _controller.play();
    _controller.setVolume(0);
    _controller.addListener(_checkVideoEnd);
  }

  void _checkVideoEnd() {
    if (_controller.value.isInitialized &&
        _controller.value.position >= _controller.value.duration) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    _controller.removeListener(_checkVideoEnd);
    
    // Get the app manager to determine where to go
    final appManager = Provider.of<AppManager>(context, listen: false);
    
    // Determine the next screen based on onboarding progress
    Widget nextScreen;
    
    // Check if user is logged in
    if (appManager.currentUser != null && appManager.currentUser!.isLoggedIn) {
      nextScreen = const DashboardScreen();
    } else {
      // Check onboarding progress
      final progress = appManager.getOnboardingProgress();
      
      switch (progress) {
        case OnboardingProgress.completed:
          nextScreen = const DashboardScreen();
          break;
        case OnboardingProgress.salesRepLogin:
          nextScreen = const SalesRepLoginScreen();
          break;
        case OnboardingProgress.businessHierarchy:
          nextScreen = const BusinessHierarchyScreen();
          break;
        case OnboardingProgress.userType:
          nextScreen = const UserTypeSelectionScreen();
          break;
        case OnboardingProgress.domain:
          nextScreen = const DomainSelectionScreen();
          break;
        case OnboardingProgress.tos:
          nextScreen = const TermsOfServiceScreen();
          break;
        case OnboardingProgress.welcome:
        default:
          nextScreen = const WelcomeScreen();
          break;
      }
    }
    
    // Navigate with fade transition
    Navigator.of(context).pushReplacement(
      PageTransitions.premiumTransition(
        nextScreen,
        duration: const Duration(milliseconds: 800),
      ),
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
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}