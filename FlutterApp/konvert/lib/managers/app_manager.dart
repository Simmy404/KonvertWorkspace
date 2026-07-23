import 'package:flutter/material.dart';
import 'error_manager.dart';
import '../services/storage_service.dart';
import '../screens/splash_screen.dart';

class AppManager {
  AppManager._internal();
  static final AppManager instance = AppManager._internal();

  /// Current application version string.
  /// Change this version to trigger a full local storage & cache reset.
  String appVersion = '1.0.0';
  static const String _appVersionKey = 'saved_app_version';

  /// Checks if app version has changed since last run.
  /// Wipes all local storage and cache if the version string differs.
  Future<void> checkAndResetOnVersionChange() async {
    try {
      final savedVersion = StorageService.instance.getString(_appVersionKey);
      if (savedVersion != appVersion) {
        debugPrint(
          'AppManager: App version changed ($savedVersion -> $appVersion). Resetting storage and cache.',
        );
        await StorageService.instance.clearAllData();
        await StorageService.instance.setString(_appVersionKey, appVersion);
      }
    } catch (e) {
      debugPrint('AppManager Error: Failed during version check reset: $e');
    }
  }

  void handleAppRestart() {
    final NavigatorState? navigator =
        ErrorManager.instance.navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (route) => false,
    );
  }

  Future<void> handleClearAndResetData() async {
    try {
      await StorageService.instance.clearAllData();
      debugPrint(
        'AppManager: Application local preferences state successfully wiped.',
      );
    } catch (e) {
      debugPrint(
        'AppManager Error: Failed to drop local storage preferences: $e',
      );
    } finally {
      handleAppRestart();
    }
  }
}
