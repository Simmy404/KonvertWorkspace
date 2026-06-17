// lib/managers/app_manager.dart
import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/domain.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class AppManager extends ChangeNotifier {
  final StorageService _storageService;
  
  // State variables
  bool _tosChecked = false;
  ThemeModeVariations _selectedTheme = ThemeModeVariations.none;
  Domain? _selectedDomain;
  CompanyHierarchy _selectedCompanyHierarchy = CompanyHierarchy.salesRep;
  UserType _selectedUserType = UserType.customer;
  User? _currentUser;
  List<Domain> _domainList = [];

  AppManager(this._storageService) {
    _loadState();
  }

  // Load state from storage
  void _loadState() {
    _tosChecked = _storageService.getTosChecked();
    _selectedTheme = _storageService.getThemeMode();
    _selectedDomain = _storageService.getSelectedDomain();
    _selectedCompanyHierarchy = _storageService.getCompanyHierarchy();
    _selectedUserType = _storageService.getUserType();
    _currentUser = _storageService.loadCurrentUser();
    _domainList = _storageService.getDomainList();
  }

  // Getters
  bool get tosChecked => _tosChecked;
  ThemeModeVariations get selectedTheme => _selectedTheme;
  Domain? get selectedDomain => _selectedDomain;
  CompanyHierarchy get selectedCompanyHierarchy => _selectedCompanyHierarchy;
  UserType get selectedUserType => _selectedUserType;
  User? get currentUser => _currentUser;
  List<Domain> get domainList => _domainList;

  // Setters with storage and notification
  set tosChecked(bool value) {
    _tosChecked = value;
    _storageService.saveTosChecked(value);
    notifyListeners();
  }

  set selectedTheme(ThemeModeVariations value) {
    _selectedTheme = value;
    _storageService.saveThemeMode(value);
    notifyListeners();
  }

  set selectedDomain(Domain? value) {
    _selectedDomain = value;
    _storageService.saveSelectedDomain(value);
    notifyListeners();
  }

  set selectedCompanyHierarchy(CompanyHierarchy value) {
    _selectedCompanyHierarchy = value;
    _storageService.saveCompanyHierarchy(value);
    notifyListeners();
  }

  set selectedUserType(UserType value) {
    _selectedUserType = value;
    _storageService.saveUserType(value);
    notifyListeners();
  }

  set currentUser(User? value) {
    _currentUser = value;
    if (value != null) {
      _storageService.saveCurrentUser(value);
    } else {
      _storageService.clearCurrentUser();
    }
    notifyListeners();
  }

  set domainList(List<Domain> value) {
    _domainList = value;
    _storageService.saveDomainList(value);
    notifyListeners();
  }

  // Convenience methods
  void toggleTheme() {
    if (_selectedTheme == ThemeModeVariations.lightMode) {
      selectedTheme = ThemeModeVariations.darkMode;
    } else {
      selectedTheme = ThemeModeVariations.lightMode;
    }
  }

  bool get isLightMode {
    return _selectedTheme == ThemeModeVariations.lightMode || 
           _selectedTheme == ThemeModeVariations.none;
  }

  bool get isDarkMode {
    return _selectedTheme == ThemeModeVariations.darkMode;
  }

  // Reset all settings
  void resetAll() {
    _storageService.clearAllData();
    _tosChecked = false;
    _selectedTheme = ThemeModeVariations.none;
    _selectedDomain = null;
    _selectedCompanyHierarchy = CompanyHierarchy.salesRep;
    _selectedUserType = UserType.customer;
    _currentUser = null;
    notifyListeners();
  }

  // Check if user is fully onboarded
  bool get isFullyOnboarded {
    return _tosChecked && 
           _selectedDomain != null && 
           _selectedUserType != UserType.customer &&
           _currentUser != null &&
           _currentUser!.isLoggedIn;
  }

  // Check onboarding progress
  OnboardingProgress getOnboardingProgress() {
    if (_currentUser != null && _currentUser!.isLoggedIn) {
      return OnboardingProgress.completed;
    }
    if (_selectedUserType == UserType.business && _selectedCompanyHierarchy != CompanyHierarchy.salesRep) {
      return OnboardingProgress.businessHierarchy;
    }
    if (_selectedUserType == UserType.business && _selectedCompanyHierarchy == CompanyHierarchy.salesRep) {
      return OnboardingProgress.salesRepLogin;
    }
    if (_selectedUserType != UserType.customer) {
      return OnboardingProgress.userType;
    }
    if (_selectedDomain != null) {
      return OnboardingProgress.domain;
    }
    if (_tosChecked) {
      return OnboardingProgress.tos;
    }
    return OnboardingProgress.welcome;
  }
}

enum OnboardingProgress {
  welcome,
  tos,
  domain,
  userType,
  businessHierarchy,
  salesRepLogin,
  completed,
}