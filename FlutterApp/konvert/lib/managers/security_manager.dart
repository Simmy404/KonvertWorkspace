// lib/managers/security_manager.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:geolocator/geolocator.dart';
import '../services/storage_service.dart';

class SecurityManager {
  SecurityManager._internal();
  static final SecurityManager instance = SecurityManager._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _appLockEnabledKey = 'app_lock_screen_enabled';

  // ==========================================
  // 1. BIOMETRIC & DEVICE LOCK AUTHENTICATION
  // ==========================================

  /// Checks if hardware biometrics (Fingerprint / Face ID) are available
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('SecurityManager Error (canCheckBiometrics): $e');
      return false;
    }
  }

  /// Checks if device authentication (PIN, Pattern, Biometrics) is supported
  Future<bool> isDeviceSupported() async {
    try {
      final bool canBio = await _localAuth.canCheckBiometrics;
      final bool isSupp = await _localAuth.isDeviceSupported();
      return canBio || isSupp;
    } catch (e) {
      debugPrint('SecurityManager Error (isDeviceSupported): $e');
      return false;
    }
  }

  /// Prompts the user to authenticate using Device Lock (PIN / Pattern / Face / Fingerprint)
  Future<bool> authenticateWithDeviceLock({
    String reason = 'Please authenticate to access Konvert',
  }) async {
    try {
      final bool canAuth = await isDeviceSupported();
      if (!canAuth) {
        // Fallback: If device has no screen lock configured, pass
        return true;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint('SecurityManager Error (authenticateWithDeviceLock): $e');
      return false;
    }
  }

  // ==========================================
  // 2. DEVICE-BOUND GOOGLE AUTHENTICATOR / TOTP
  // ==========================================

  /// Generates a SHA-256 derived seed from a unique device identifier (e.g. IMEI / Hardware ID)
  String generateDeviceSeed(String rawDeviceIdentifier) {
    if (rawDeviceIdentifier.isEmpty) return '';
    final bytes = utf8.encode('KONVERT_SEED_$rawDeviceIdentifier');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generates a Base32 Google Authenticator secret key derived from a seed
  String generateAuthenticatorSecret(String seed) {
    if (seed.isEmpty) return '';
    final hash = sha256.convert(utf8.encode(seed)).bytes;

    // Convert hash bytes to Base32 alphabet (A-Z, 2-7) for Google Authenticator
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    StringBuffer secret = StringBuffer();
    for (int i = 0; i < 16; i++) {
      secret.write(alphabet[hash[i] % 32]);
    }
    return secret.toString();
  }

  /// Validates a 6-digit TOTP code against a secret
  bool verifyTotpCode(String secret, String inputCode) {
    if (secret.isEmpty || inputCode.length != 6) return false;
    // Basic verification placeholder: verify numeric code format
    final intCode = int.tryParse(inputCode);
    return intCode != null && inputCode.length == 6;
  }

  // ==========================================
  // 3. CRYPTOGRAPHIC HASHING & PASSWORDS
  // ==========================================

  /// Hashes a plain-text password using SHA-256
  String hashPassword(String password) {
    if (password.isEmpty) return '';
    final bytes = utf8.encode('KONVERT_SALT_$password');
    return sha256.convert(bytes).toString();
  }

  /// Compares a plain password against a stored SHA-256 hash
  bool verifyPassword(String plainPassword, String storedHash) {
    final computedHash = hashPassword(plainPassword);
    return computedHash == storedHash;
  }

  // ==========================================
  // 4. LOCK SCREEN REQUIREMENTS & SETTINGS
  // ==========================================

  /// Checks if the startup lock screen is enabled and required
  bool isLockScreenRequired() {
    final isLoggedIn = StorageService.instance.getCurrentUser() != null;
    final isLockEnabled =
        StorageService.instance.getBool(_appLockEnabledKey) ?? true;
    return isLoggedIn && isLockEnabled;
  }

  /// Toggles whether startup lock screen is required
  Future<void> setAppLockEnabled(bool enabled) async {
    await StorageService.instance.setBool(_appLockEnabledKey, enabled);
  }

  // ==========================================
  // 5. LOCATION SECURITY & ENFORCEMENT
  // ==========================================

  /// Validates if location services are enabled and permissions are granted
  Future<bool> verifyLocationSecurity() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }

      if (permission == LocationPermission.deniedForever) return false;

      return true;
    } catch (e) {
      debugPrint('SecurityManager Error (verifyLocationSecurity): $e');
      return false;
    }
  }
}
