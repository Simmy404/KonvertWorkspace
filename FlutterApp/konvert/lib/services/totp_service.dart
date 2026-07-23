// lib/services/totp_service.dart
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// RFC 6238 Time-based One-Time Password (TOTP) Service
/// Compatible with Google Authenticator, Microsoft Authenticator, and Authy.
class TotpService {
  TotpService._internal();
  static final TotpService instance = TotpService._internal();

  /// Default demo secret key for testing (Base32 format)
  /// Google Authenticator Key: JBSWY3DPEHPK3PXP
  static const String defaultSecret = 'JBSWY3DPEHPK3PXP';

  /// Standard Base32 decoding (RFC 4648)
  Uint8List _base32Decode(String input) {
    const base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final cleanInput = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');

    final List<int> bytes = [];
    int buffer = 0;
    int bitsLeft = 0;

    for (int i = 0; i < cleanInput.length; i++) {
      final char = cleanInput[i];
      final val = base32Chars.indexOf(char);
      if (val < 0) continue;

      buffer = (buffer << 5) | val;
      bitsLeft += 5;

      if (bitsLeft >= 8) {
        bitsLeft -= 8;
        bytes.add((buffer >> bitsLeft) & 0xFF);
      }
    }

    return Uint8List.fromList(bytes);
  }

  /// Generate a 6-digit TOTP code for a specific time interval [counter]
  String generateTotpForCounter(String secret, int counter) {
    try {
      final keyBytes = _base32Decode(secret);
      if (keyBytes.isEmpty) return '000000';

      // 8-byte big-endian representation of counter
      final counterBytes = Uint8List(8);
      var tempCounter = counter;
      for (int i = 7; i >= 0; i--) {
        counterBytes[i] = tempCounter & 0xFF;
        tempCounter >>= 8;
      }

      // HMAC-SHA1
      final hmac = Hmac(sha1, keyBytes);
      final hash = hmac.convert(counterBytes).bytes;

      // Dynamic Truncation
      final offset = hash[hash.length - 1] & 0x0F;
      final binaryCode =
          ((hash[offset] & 0x7F) << 24) |
          ((hash[offset + 1] & 0xFF) << 16) |
          ((hash[offset + 2] & 0xFF) << 8) |
          (hash[offset + 3] & 0xFF);

      final otp = binaryCode % 1000000;
      return otp.toString().padLeft(6, '0');
    } catch (e) {
      debugPrint('Error generating TOTP: $e');
      return '000000';
    }
  }

  /// Generate current 6-digit TOTP code for given [secret]
  String generateCurrentTotp([String secret = defaultSecret]) {
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeStep = nowSeconds ~/ 30;
    return generateTotpForCounter(secret, timeStep);
  }

  /// Verify user-entered 6-digit OTP code against given [secret]
  /// Checks window [-1, 0, +1] (30 seconds before, current, 30 seconds after)
  /// to handle any minor device clock skew seamlessly.
  bool verifyTotp(String userCode, [String secret = defaultSecret]) {
    final cleanCode = userCode.trim().replaceAll(RegExp(r'\s+'), '');
    if (cleanCode.length != 6) return false;

    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final currentCounter = nowSeconds ~/ 30;

    for (int delta = -1; delta <= 1; delta++) {
      final validCode = generateTotpForCounter(secret, currentCounter + delta);
      if (cleanCode == validCode) {
        return true;
      }
    }

    return false;
  }
}
