import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../managers/location_manager.dart';

class DashboardViewModel extends ChangeNotifier {
  bool needsInitialSync = false;
  int selectedIndex = 0; // 0 = Home, 1 = Bookings, 2 = Tour Plan, 3 = Report

  int bricksCount = 0;
  int productsCount = 0;
  int chemistsCount = 0;
  bool loadingCounts = true;

  DashboardViewModel() {
    _init();
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
    notifyListeners();
  }

  void setNeedsInitialSync(bool value) {
    needsInitialSync = value;
    notifyListeners();
  }

  Future<void> loadCatalogCounts() async {
    loadingCounts = true;
    notifyListeners();
    
    try {
      bricksCount = await DatabaseService.instance.getBricksCount();
      productsCount = await DatabaseService.instance.getProductsCount();
      chemistsCount = await DatabaseService.instance.getChemistsCount();
    } catch (e) {
      // Ignored for now
    } finally {
      loadingCounts = false;
      notifyListeners();
    }
  }
}
