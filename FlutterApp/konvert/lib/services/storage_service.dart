import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart'; // Add this import to the top of storage_service.dart
import 'dart:convert';
import 'database_service.dart';
import '../models/user.dart';

class StorageService {
  StorageService._internal();
  static final StorageService instance = StorageService._internal();

  SharedPreferences? _prefs;

  /// Initializes the storage engine.
  /// MUST be called in main.dart before initializing other managers.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      // If the hardware storage fails on boot, throw a critical blocking error
      ErrorManager.instance.showCriticalErrorScreen(
        ErrorStruct(
          code: 'STR-001',
          technicalDetails: 'Storage engine failed to mount: $e',
        ),
      );
    }
  }

  // ==========================================
  // DATABASE STUFF
  // ==========================================

  // --- TARGET STORAGE (SharedPreferences) ---
  static const String _targetMonthKey = 'target_month';
  static const String _targetTotalKey = 'target_total';
  static const String _targetTodayKey = 'target_today';
  static const String _targetOrdersKey = 'target_orders';
  static const String _lastSyncDateKey = 'last_sync_date';

  Future<void> setTargets({
    required String monthTarget,
    required String totalSales,
    required String todaySales,
    required String noOfOrders,
  }) async {
    await setString(_targetMonthKey, monthTarget);
    await setString(_targetTotalKey, totalSales);
    await setString(_targetTodayKey, todaySales);
    await setString(_targetOrdersKey, noOfOrders);
  }

  Map<String, String> getTargets() {
    return {
      'month_target': getString(_targetMonthKey) ?? '0',
      'total_sales': getString(_targetTotalKey) ?? '0',
      'today_sales': getString(_targetTodayKey) ?? '0',
      'no_of_orders': getString(_targetOrdersKey) ?? '0',
    };
  }

  Future<bool> setLastSyncDate(String dateStr) async {
    return await setString(_lastSyncDateKey, dateStr);
  }

  String? getLastSyncDate() {
    return getString(_lastSyncDateKey);
  }

  // --- DATABASE EXPOSURE (SQLite) ---
  Future<void> saveSyncBricks(List<dynamic> brickList) async {
    try {
      await DatabaseService.instance.syncBricks(brickList);
    } catch (e) {
      _handleSilentError('DB-001', 'Failed to save bricks: $e');
    }
  }

  Future<void> saveSyncCustomers(List<dynamic> customerList) async {
    try {
      await DatabaseService.instance.syncCustomers(customerList);
    } catch (e) {
      _handleSilentError('DB-002', 'Failed to save customers: $e');
    }
  }

  Future<void> saveSyncProducts(List<dynamic> productList) async {
    try {
      await DatabaseService.instance.syncProducts(productList);
    } catch (e) {
      _handleSilentError('DB-003', 'Failed to save products: $e');
    }
  }

  Future<void> saveSyncDoctors(List<dynamic> doctorList) async {
    try {
      await DatabaseService.instance.syncDoctors(doctorList);
    } catch (e) {
      _handleSilentError('DB-004', 'Failed to save doctors: $e');
    }
  }

  // ==========================================
  // API KEY DATA
  // ==========================================

  static const String _apiKey = 'saved_api_key';

  // --- API KEY STORAGE ---
  Future<bool> setApiKey(String key) async {
    return await setString(_apiKey, key);
  }

  String? getApiKey() {
    return getString(_apiKey);
  }

  // ==========================================
  // USER DATA
  // ==========================================

  static const String _currentUserKey = 'current_user_cache';

  // --- USER STORAGE ---
  Future<bool> setCurrentUser(User user) async {
    try {
      final String payload = jsonEncode(user.toJson());
      return await setString(_currentUserKey, payload);
    } catch (e) {
      _handleSilentError('STR-009', 'Failed to encode user data: $e');
      return false;
    }
  }

  User? getCurrentUser() {
    try {
      final String? payload = getString(_currentUserKey);
      if (payload != null) {
        final Map<String, dynamic> decoded = jsonDecode(payload);
        return User(
          id: decoded['id'] as int,
          name: decoded['name'] as String,
          bid: decoded['bid'] as int,
          category: decoded['category'] as String,
          isOnline: decoded['isOnline'] as bool,
          googleApi: decoded['googleApi'] as String,
          username: decoded['username'] as String,
        );
      }
    } catch (e) {
      _handleSilentError('STR-010', 'Failed to decode user data: $e');
    }
    return null;
  }

  Future<bool> logoutUser() async {
    try {
      if (_prefs == null) await init();
      return await _prefs!.remove(_currentUserKey);
    } catch (e) {
      _handleSilentError('STR-011', 'Failed to clear user cache: $e');
      return false;
    }
  }

  // ==========================================
  // COMPANY DATA
  // ==========================================

  static const String _currentCompanyKey = 'current_company_cache';

  /// Saves the active company to local storage
  Future<bool> setCurrentCompany({
    required String name,
    required String url,
  }) async {
    try {
      final String payload = jsonEncode({'name': name, 'url': url});
      return await setString(_currentCompanyKey, payload);
    } catch (e) {
      _handleSilentError('STR-007', 'Failed to encode company data: $e');
      return false;
    }
  }

  /// Retrieves the active company from local storage. Returns null if none exists.
  Map<String, String>? getCurrentCompany() {
    try {
      final String? payload = getString(_currentCompanyKey);
      if (payload != null) {
        final Map<String, dynamic> decoded = jsonDecode(payload);
        return {
          'name': decoded['name'].toString(),
          'url': decoded['url'].toString(),
        };
      }
    } catch (e) {
      _handleSilentError('STR-008', 'Failed to decode company data: $e');
    }
    return null;
  }

  /// Clears active company and API key from local storage
  Future<bool> clearCurrentCompany() async {
    try {
      if (_prefs == null) await init();
      await _prefs!.remove(_currentCompanyKey);
      await _prefs!.remove(_apiKey);
      return true;
    } catch (e) {
      _handleSilentError('STR-012', 'Failed to clear company data: $e');
      return false;
    }
  }

  // ==========================================
  // SMART DATA WRITERS
  // ==========================================

  Future<bool> setString(String key, String value) async {
    try {
      if (_prefs == null) await init();
      return await _prefs!.setString(key, value);
    } catch (e) {
      _handleSilentError('STR-002', e.toString());
      return false;
    }
  }

  Future<bool> setBool(String key, bool value) async {
    try {
      if (_prefs == null) await init();
      return await _prefs!.setBool(key, value);
    } catch (e) {
      _handleSilentError('STR-003', e.toString());
      return false;
    }
  }

  // ==========================================
  // SMART DATA READERS
  // ==========================================

  String? getString(String key) {
    try {
      return _prefs?.getString(key);
    } catch (e) {
      _handleSilentError('STR-004', e.toString());
      return null;
    }
  }

  bool? getBool(String key) {
    try {
      return _prefs?.getBool(key);
    } catch (e) {
      _handleSilentError('STR-005', e.toString());
      return null;
    }
  }

  // ==========================================
  // GLOBAL LIFECYCLE HOOKS
  // ==========================================

  /// Safely wipes the entire local cache.
  Future<bool> clearAllData() async {
    try {
      if (_prefs == null) await init();
      return await _prefs!.clear();
    } catch (e) {
      _handleSilentError('STR-006', e.toString());
      return false;
    }
  }

  /// Internal error router for non-fatal read/write failures.
  void _handleSilentError(String code, String details) {
    debugPrint('StorageService Error [$code]: $details');
    ErrorManager.instance.showToastError(
      ErrorStruct(code: code, technicalDetails: details),
      3,
    );
  }
}
