import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/api_service.dart';
import '../../managers/location_manager.dart';

class DashboardViewModel extends ChangeNotifier {
  bool _isDisposed = false;
  bool needsInitialSync = false;
  int selectedIndex = 0; // 0 = Home, 1 = Bookings, 2 = Tour Plan, 3 = Report

  int bricksCount = 0;
  int productsCount = 0;
  int chemistsCount = 0;
  bool loadingCounts = true;
  bool isRefreshingTargets = false;

  DashboardViewModel() {
    _init();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> _init() async {
    // Optionally fetch location immediately
    await LocationManager.instance.fetchCurrentLocation();
    
    // We expect the UI to call checkInitialSync since it needs context for navigation
    // but the counts can be loaded here:
    await loadCatalogCounts();
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    _safeNotifyListeners();
  }

  void setNeedsInitialSync(bool value) {
    needsInitialSync = value;
    _safeNotifyListeners();
  }

  Future<void> refreshTargets() async {
    if (isRefreshingTargets) return;
    isRefreshingTargets = true;
    _safeNotifyListeners();

    try {
      await ApiService.instance.syncTarget();
    } catch (e) {
      debugPrint('Error refreshing targets: $e');
    } finally {
      isRefreshingTargets = false;
      _safeNotifyListeners();
    }
  }

  Future<void> loadCatalogCounts() async {
    loadingCounts = true;
    _safeNotifyListeners();
    
    try {
      bricksCount = await DatabaseService.instance.getBricksCount();
      productsCount = await DatabaseService.instance.getProductsCount();
      chemistsCount = await DatabaseService.instance.getChemistsCount();
    } catch (e) {
      // Ignored for now
    } finally {
      loadingCounts = false;
      _safeNotifyListeners();
    }
  }
}
