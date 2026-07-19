import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/error_manager.dart';
import '../models/error_struct.dart';

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
      ErrorStruct(
        code: code,
        technicalDetails: details,
      ),
      3, 
    );
  }
}