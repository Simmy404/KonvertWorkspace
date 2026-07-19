import 'package:Konvert/managers/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/error_struct.dart';
import '../managers/app_manager.dart'; // Pointing to your new AppManager location

class ErrorScreen extends StatelessWidget {
  final ErrorStruct error;

  const ErrorScreen({
    super.key,
    required this.error,
  });

  Future<void> _launchSupportUrl() async {
    final Uri url = Uri.parse('https://example.com/support');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch support link: $url');
      }
    } catch (e) {
      debugPrint('Error attempting to launch support URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image Asset Layer (Matches Error Screen_Dark.png design parameters)
          Positioned.fill(
            child: Image.asset(
              ThemeManager.instance.getErrorBG(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(color: Colors.black),
            ),
          ),

          // Main Screen Component Layout Stack
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                children: [
                  const Spacer(flex: 4),
                  const Text(
                    'Uh Oh!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 4.0), // Moves the shadow down by 4 pixels
                          blurRadius: 10.0,       // Softens the shadow
                          color: Color.fromRGBO(0, 0, 0, 0.5), // 50% opacity black
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                  Text(
                    'An Error Occured',
                    style: TextStyle(
                      color: ThemeManager.instance.getMatchColor(),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 0),
                  Text(
                    error.code,
                    style: TextStyle(
                      color: ThemeManager.instance.getMatchColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(flex: 2),

                  // Button 1: Primary Restart Capsule pointing directly to the AppManager instance
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () => AppManager.instance.handleAppRestart(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeManager.instance.getPrimaryColor(),
                        foregroundColor: ThemeManager.instance.getContrastColor(),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Restart App',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Button 2: Secondary Dark Capsule pointing directly to the AppManager instance
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () => AppManager.instance.handleClearAndResetData(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeManager.instance.getMatchColor().withOpacity(0.1),
                        foregroundColor: ThemeManager.instance.getMatchColor(),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Clear Data and Reset App',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(color: ThemeManager.instance.getMatchColor().withOpacity(0.2), thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('or', style: TextStyle(color: ThemeManager.instance.getMatchColor().withOpacity(0.6), fontSize: 15)),
                      ),
                      Expanded(child: Divider(color: ThemeManager.instance.getMatchColor().withOpacity(0.2), thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _launchSupportUrl,
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
                    child: Text(
                      'Contact Support',
                      style: TextStyle(
                        color: ThemeManager.instance.getMatchColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: ThemeManager.instance.getMatchColor(),
                        decorationThickness: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}