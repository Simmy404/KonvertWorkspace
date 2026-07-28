// lib/managers/security_manager.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:geolocator/geolocator.dart';

class SecurityManager {
  SecurityManager._internal();
  static final SecurityManager instance = SecurityManager._internal();

  // ==========================================
  // 1. CRYPTOGRAPHIC HASHING & PASSWORDS
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
  // 2. LOCATION SECURITY & ENFORCEMENT
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
