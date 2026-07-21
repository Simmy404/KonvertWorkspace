// lib/screens/error_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/error_struct.dart';
import '../managers/app_manager.dart'; 
import '../managers/theme_manager.dart';
import '../managers/error_manager.dart';

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
        ErrorManager.instance.showToastError(
          const ErrorStruct(code: 'ERR-001', technicalDetails: 'Could not launch support link.'), 
          3
        );
      }
    } catch (e) {
      ErrorManager.instance.showToastError(
        ErrorStruct(code: 'ERR-002', technicalDetails: e.toString()), 
        3
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents the system back button/swipe from popping the route
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        // Fire toast when they try to go back
        ErrorManager.instance.showToastError(
          const ErrorStruct(
            code: 'SYS-001', 
            technicalDetails: 'Cannot go back from a critical error. Please resolve or restart.'
          ),
          3,
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                ThemeManager.instance.getErrorBG(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(color: Colors.black),
              ),
            ),
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
                            offset: Offset(0, 4.0),
                            blurRadius: 10.0,
                            color: Color.fromRGBO(0, 0, 0, 0.5),
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
      ),
    );
  }
}