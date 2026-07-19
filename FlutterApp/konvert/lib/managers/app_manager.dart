import 'package:flutter/material.dart';
import 'error_manager.dart';
import '../services/storage_service.dart';
import '../screens/splash_screen.dart';

class AppManager {
  AppManager._internal();
  static final AppManager instance = AppManager._internal();

  void handleAppRestart() {
    final NavigatorState? navigator = ErrorManager.instance.navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (route) => false,
    );
  }

  Future<void> handleClearAndResetData() async {
    try {
      // Safely nuke all data utilizing the unified storage pipeline
      await StorageService.instance.clearAllData();
      debugPrint('AppManager: Application local preferences state successfully wiped.');
    } catch (e) {
      debugPrint('AppManager Error: Failed to drop local storage preferences: $e');
    } finally {
      handleAppRestart();
    }
  }
}