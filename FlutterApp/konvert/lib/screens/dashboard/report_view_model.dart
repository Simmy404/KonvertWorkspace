import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/report_data.dart';

class ReportViewModel extends ChangeNotifier {
  bool isLoading = true;
  bool hasError = false;
  String selectedFilter = 'month'; // 'today', 'week', 'month', 'year', 'all'
  int selectedSegment = 0; // 0: Overview, 1: Sales, 2: Financials
  ReportData? reportData;

  ReportViewModel() {
    _fetchData();
  }

  void setFilter(String filter) {
    if (selectedFilter == filter) return;
    selectedFilter = filter;
    _fetchData();
  }

  void setSegment(int index) {
    if (selectedSegment == index) return;
    selectedSegment = index;
    notifyListeners();
  }

  Future<void> _fetchData() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      reportData = await ApiService.instance.fetchReportingData(selectedFilter);
      hasError = reportData == null;
    } catch (_) {
      reportData = null;
      hasError = true;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _fetchData();
  }
}
