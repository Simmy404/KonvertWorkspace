import 'package:flutter/material.dart';
import '../models/error_struct.dart';
import '../screens/error_screen.dart';
import '../utils/page_transitions.dart';

class ErrorManager {
  ErrorManager._internal();
  static final ErrorManager instance = ErrorManager._internal();

  // Attach these keys to your MaterialApp to handle globally detached executions
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// FUNCTION 1: Display Toast Banner for a custom time duration
  void showToastError(ErrorStruct error, int seconds) {
    final ScaffoldMessengerState? messenger = messengerKey.currentState;
    if (messenger == null) return;

    // Instantly wipe any current toasts to prevent overlapping queues
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        duration: Duration(seconds: seconds),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF222222),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Something went wrong (Code: ${error.code})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FUNCTION 2: Route users completely to the dedicated blocking error screen
  void showCriticalErrorScreen(ErrorStruct error) {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator == null) return;

    // Push replacement drops old rendering layers to protect processing loops
    navigator.pushReplacement(
      PageTransitions.fadeTransition(
        ErrorScreen(error: error),
      ),
    );
  }
}