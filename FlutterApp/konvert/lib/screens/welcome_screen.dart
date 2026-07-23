// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../managers/theme_manager.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart';
import '../utils/page_transitions.dart';
import '../screens/tos_screen.dart';
import 'explore_features_sheet.dart';

class WelcomeScreen extends StatefulWidget {
  final VideoPlayerController preinitializedController;

  const WelcomeScreen({
    super.key,
    required this.preinitializedController,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final VideoPlayerController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = widget.preinitializedController;
    
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
      // Major failure: Welcome screen background is completely dead
      ErrorManager.instance.showCriticalErrorScreen(
        ErrorStruct(
          code: 'WEL-001',
          technicalDetails: 'Fallback initialization retry failed: $e'
        )
      );
    }
  }

  Future<void> _launchHelpUrl() async {
    final Uri url = Uri.parse('https://example.com/support'); 

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) { 
        ErrorManager.instance.showToastError(
          const ErrorStruct(code: 'WEL-002', technicalDetails: 'Could not launch URL'), 
          3
        );
      }
    } catch (e) {
      ErrorManager.instance.showToastError(
        ErrorStruct(code: 'WEL-003', technicalDetails: e.toString()), 
        3
      );
    }
  }

  @override
  void dispose() {
    _bgController.dispose(); 
    super.dispose();
  }


  void _startTOSPage() {
    Navigator.push(
      context,
      PageTransitions.fadeSlideUpTransition(const TosScreen()), 
    );
  }

  void _openExploreFeatures() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExploreFeaturesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.instance.getContrastColor(), 
      body: Stack(
        children: [
          if (_bgController.value.isInitialized)
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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0), 
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
                      return const Icon(Icons.broken_image, color: Colors.white, size: 32); 
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
                        TextSpan(text: 'Track sales, manage teams, and generate\ninsights from anywhere.\n'), 
                      ],
                    ),
                  ),
                  const SizedBox(height: 48), 
                  SizedBox(
                    width: double.infinity, 
                    height: 64, 
                    child: ElevatedButton(
                      onPressed: _startTOSPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeManager.instance.getPrimaryColor(), 
                        foregroundColor: ThemeManager.instance.getContrastColor(), 
                        shape: const StadiumBorder(), 
                        elevation: 0, 
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3), 
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), 
                  Center(
                    child: TextButton(
                      onPressed: _openExploreFeatures, 
                      style: TextButton.styleFrom(
                        foregroundColor: ThemeManager.instance.getMatchColor(), 
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), 
                      ),
                      child: const Text(
                        'Explore Features',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2), 
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