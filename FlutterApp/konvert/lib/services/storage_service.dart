// lib/services/storage_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/domain.dart';
import '../models/user.dart';
import '../models/enums.dart';

class StorageService {
  final SharedPreferences _prefs;
  
  // Keys for storage
  static const String KEY_TOS_CHECKED = 'tos_checked';
  static const String KEY_THEME_MODE = 'theme_mode';
  static const String KEY_SELECTED_DOMAIN = 'selected_domain';
  static const String KEY_COMPANY_HIERARCHY = 'company_hierarchy';
  static const String KEY_USER_TYPE = 'user_type';
  static const String KEY_CURRENT_USER = 'current_user';
  static const String KEY_APP_VERSION = 'app_version';
  static const String KEY_DOMAIN_LIST = 'domain_list';

  StorageService(this._prefs);

  // ==================== Onboarding State Management ====================
  
  // TOS Checked
  bool getTosChecked() {
    return _prefs.getBool(KEY_TOS_CHECKED) ?? false;
  }
  
  Future<void> saveTosChecked(bool value) async {
    await _prefs.setBool(KEY_TOS_CHECKED, value);
  }
  
  // Theme Mode
  ThemeModeVariations getThemeMode() {
    final value = _prefs.getString(KEY_THEME_MODE);
    if (value == null) return ThemeModeVariations.none;
    
    try {
      return ThemeModeVariations.values.firstWhere(
        (e) => e.toString() == value,
        orElse: () => ThemeModeVariations.none,
      );
    } catch (e) {
      return ThemeModeVariations.none;
    }
  }
  
  Future<void> saveThemeMode(ThemeModeVariations mode) async {
    await _prefs.setString(KEY_THEME_MODE, mode.toString());
  }
  
  // Selected Domain
  Domain? getSelectedDomain() {
    final jsonString = _prefs.getString(KEY_SELECTED_DOMAIN);
    if (jsonString == null) return null;
    
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return Domain.fromMap(map);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading domain: $e');
      }
      return null;
    }
  }
  
  Future<void> saveSelectedDomain(Domain? domain) async {
    if (domain == null) {
      await _prefs.remove(KEY_SELECTED_DOMAIN);
    } else {
      final jsonString = jsonEncode(domain.toMap());
      await _prefs.setString(KEY_SELECTED_DOMAIN, jsonString);
    }
  }
  
  // Company Hierarchy
  CompanyHierarchy getCompanyHierarchy() {
    final value = _prefs.getString(KEY_COMPANY_HIERARCHY);
    if (value == null) return CompanyHierarchy.salesRep;
    
    try {
      return CompanyHierarchy.values.firstWhere(
        (e) => e.toString() == value,
        orElse: () => CompanyHierarchy.salesRep,
      );
    } catch (e) {
      return CompanyHierarchy.salesRep;
    }
  }
  
  Future<void> saveCompanyHierarchy(CompanyHierarchy hierarchy) async {
    await _prefs.setString(KEY_COMPANY_HIERARCHY, hierarchy.toString());
  }
  
  // User Type
  UserType getUserType() {
    final value = _prefs.getString(KEY_USER_TYPE);
    if (value == null) return UserType.customer;
    
    try {
      return UserType.values.firstWhere(
        (e) => e.toString() == value,
        orElse: () => UserType.customer,
      );
    } catch (e) {
      return UserType.customer;
    }
  }
  
  Future<void> saveUserType(UserType type) async {
    await _prefs.setString(KEY_USER_TYPE, type.toString());
  }
  
  // ==================== Domain List Management ====================
  
  List<Domain> getDomainList() {
    final jsonString = _prefs.getString(KEY_DOMAIN_LIST);
    if (jsonString == null) return _getDefaultDomains();
    
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => Domain.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading domain list: $e');
      }
      return _getDefaultDomains();
    }
  }
  
  Future<void> saveDomainList(List<Domain> domains) async {
    final list = domains.map((d) => d.toMap()).toList();
    final jsonString = jsonEncode(list);
    await _prefs.setString(KEY_DOMAIN_LIST, jsonString);
  }
  
  List<Domain> _getDefaultDomains() {
    return [
      Domain(
        name: 'Bristol',
        url: 'https://www.bristolpharma.com',
        apiKey: '',
      ),
      Domain(
        name: 'Hassan Pharma',
        url: 'https://www.hassanpharma.com',
        apiKey: '',
      ),
    ];
  }
  
  // ==================== User Management ====================
  
  // Save current user
  Future<void> saveCurrentUser(User user) async {
    final jsonString = jsonEncode(user.toJson());
    await _prefs.setString(KEY_CURRENT_USER, jsonString);
    
    if (kDebugMode) {
      debugPrint('User saved: ${user.name} (ID: ${user.id})');
    }
  }
  
  // Load current user
  User? loadCurrentUser() {
    final jsonString = _prefs.getString(KEY_CURRENT_USER);
    if (jsonString == null) return null;
    
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return User.fromJson(map);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading user: $e');
      }
      return null;
    }
  }
  
  // Clear current user (logout)
  Future<void> clearCurrentUser() async {
    await _prefs.remove(KEY_CURRENT_USER);
    
    if (kDebugMode) {
      debugPrint('User logged out');
    }
  }
  
  // Check if user is logged in
  bool isUserLoggedIn() {
    final user = loadCurrentUser();
    return user != null && user.isLoggedIn;
  }
  
  // ==================== App Version Management ====================
  
  // Get stored app version
  String? getStoredAppVersion() {
    return _prefs.getString(KEY_APP_VERSION);
  }
  
  // Save current app version
  Future<void> saveAppVersion(String version) async {
    await _prefs.setString(KEY_APP_VERSION, version);
  }
  
  // Check if app version has changed and reset if needed
  Future<bool> checkAndResetIfVersionChanged(String currentVersion) async {
    final storedVersion = getStoredAppVersion();
    
    if (storedVersion == null || storedVersion != currentVersion) {
      await clearAllData();
      await saveAppVersion(currentVersion);
      
      if (kDebugMode) {
        debugPrint('App version changed from $storedVersion to $currentVersion - Data reset');
      }
      
      return true;
    }
    
    return false;
  }
  
  // ==================== Complete Data Management ====================
  
  // Clear all data (logout + clear settings)
  Future<void> clearAllData() async {
    await clearCurrentUser();
    await _prefs.remove(KEY_TOS_CHECKED);
    await _prefs.remove(KEY_SELECTED_DOMAIN);
    await _prefs.remove(KEY_COMPANY_HIERARCHY);
    await _prefs.remove(KEY_USER_TYPE);
    await _prefs.remove(KEY_THEME_MODE);
    // Don't clear domain list or app version
  }
  
  // Reset everything including app version
  Future<void> fullReset(String currentVersion) async {
    await _prefs.clear();
    await saveAppVersion(currentVersion);
    
    if (kDebugMode) {
      debugPrint('Full app reset performed');
    }
  }
  
  // Logout user (preserve settings)
  Future<void> logout() async {
    final user = loadCurrentUser();
    if (user != null) {
      final loggedOutUser = user.withoutLogin();
      await saveCurrentUser(loggedOutUser);
    }
  }
  
  // Save all onboarding state
  Future<void> saveOnboardingState({
    required bool tosChecked,
    required ThemeModeVariations themeMode,
    required Domain? selectedDomain,
    required CompanyHierarchy companyHierarchy,
    required UserType userType,
  }) async {
    await saveTosChecked(tosChecked);
    await saveThemeMode(themeMode);
    await saveSelectedDomain(selectedDomain);
    await saveCompanyHierarchy(companyHierarchy);
    await saveUserType(userType);
  }
  
  // Load all onboarding state
  Map<String, dynamic> loadOnboardingState() {
    return {
      'tosChecked': getTosChecked(),
      'themeMode': getThemeMode(),
      'selectedDomain': getSelectedDomain(),
      'companyHierarchy': getCompanyHierarchy(),
      'userType': getUserType(),
    };
  }
  
  // ==================== Legacy/Utility Methods ====================
  
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  
  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  
  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  
  double? getDouble(String key) => _prefs.getDouble(key);
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);
  
  List<String>? getStringList(String key) => _prefs.getStringList(key);
  Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);
  
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
  bool containsKey(String key) => _prefs.containsKey(key);
}