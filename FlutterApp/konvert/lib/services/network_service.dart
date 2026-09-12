// lib/services/network_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class NetworkService with ChangeNotifier {
  NetworkService._internal() {
    startMonitoring();
  }
  static final NetworkService instance = NetworkService._internal();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Timer? _timer;
  bool _isChecking = false;

  /// Starts periodic connectivity checks every 3 seconds for responsive detection.
  void startMonitoring() {
    _timer?.cancel();
    checkConnection();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkConnection();
    });
  }

  /// Stops periodic polling if needed.
  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  /// Actively checks whether an external internet connection is currently reachable.
  Future<bool> checkConnection() async {
    if (_isChecking) return _isConnected;
    _isChecking = true;

    bool connected = false;
    try {
      // 1. Primary check: DNS resolution to google.com
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connected = true;
      }
    } catch (_) {
      // 2. Secondary fallback: Cloudflare DNS
      try {
        final result = await InternetAddress.lookup('one.one.one.one')
            .timeout(const Duration(seconds: 2));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          connected = true;
        }
      } catch (_) {
        // 3. Tertiary fallback: user's configured company server domain
        try {
          final company = StorageService.instance.getCurrentCompany();
          if (company != null && company['url'] != null) {
            String rawUrl = company['url']!;
            rawUrl = rawUrl.replaceFirst(RegExp(r'^https?://'), '');
            final host = rawUrl.split('/')[0].split(':')[0].trim();
            if (host.isNotEmpty) {
              final res = await InternetAddress.lookup(host)
                  .timeout(const Duration(seconds: 2));
              if (res.isNotEmpty && res[0].rawAddress.isNotEmpty) {
                connected = true;
              }
            }
          }
        } catch (_) {
          connected = false;
        }
      }
    } finally {
      _isChecking = false;
    }

    if (_isConnected != connected) {
      _isConnected = connected;
      notifyListeners();
    }

    return _isConnected;
  }
}
