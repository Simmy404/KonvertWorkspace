import 'package:flutter/material.dart';
import '../../models/tour_plan.dart';
import '../../services/storage_service.dart';
import '../../services/database_service.dart';
import '../../managers/activity_manager.dart';
import 'dart:math';

class TourPlanViewModel extends ChangeNotifier {
  bool _isDisposed = false;
  bool isLoading = true;

  MonthlyTourPlan? _currentPlan;
  MonthlyTourPlan? get currentPlan => _currentPlan;

  // Caches for quick lookups
  List<Map<String, dynamic>> allBricks = [];
  Map<String, List<Map<String, dynamic>>> customersByBrick = {};

  TourPlanViewModel() {
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
    isLoading = true;
    _safeNotifyListeners();

    await _loadCatalogData();
    _currentPlan = StorageService.instance.getTourPlan();
    
    // If no plan, or draft/rejected, and no week 1 exists, initialize it.
    if (_currentPlan == null || _currentPlan!.weeks.isEmpty) {
      _initDraftPlan();
    }

    isLoading = false;
    _safeNotifyListeners();
  }

  Future<void> _loadCatalogData() async {
    try {
      allBricks = await DatabaseService.instance.getAllBricks();
      final customers = await DatabaseService.instance.getAllCustomers();
      
      customersByBrick.clear();
      for (var c in customers) {
        final brickId = c['customer_brickid']?.toString() ?? '';
        if (brickId.isNotEmpty) {
          if (!customersByBrick.containsKey(brickId)) {
            customersByBrick[brickId] = [];
          }
          customersByBrick[brickId]!.add(c);
        }
      }
    } catch (e) {
      debugPrint('Error loading catalog for tour plan: $e');
    }
  }

  void _initDraftPlan() {
    final now = DateTime.now();
    // Calculate the next coming Monday. 
    int daysUntilMonday = 8 - now.weekday; 
    if (now.weekday != DateTime.monday) {
      daysUntilMonday = 8 - now.weekday;
    } else {
      daysUntilMonday = 0; // If today is Monday, start today.
    }

    final startDate = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilMonday));

    List<DailyTourPlan> week1Days = [];
    for (int i = 0; i < 7; i++) {
      week1Days.add(DailyTourPlan(
        date: startDate.add(Duration(days: i)),
        type: DailyTourPlanType.off, // default to off
      ));
    }

    _currentPlan = MonthlyTourPlan(
      status: TourPlanStatus.draft,
      weeks: [WeeklyTourPlan(days: week1Days)],
    );
  }

  void updateDayType(int dayIndex, DailyTourPlanType type) {
    if (_currentPlan == null || _currentPlan!.weeks.isEmpty) return;
    
    final currentDay = _currentPlan!.weeks[0].days[dayIndex];
    DailyTourPlan updatedDay = currentDay.copyWith(
      type: type,
      isConfigured: true,
    );

    // If changing away from field, clear selections
    if (type != DailyTourPlanType.field) {
      updatedDay = updatedDay.copyWith(brickId: null, customerIds: []);
    }

    // If remote, pseudo randomize some doctors (for now)
    if (type == DailyTourPlanType.remote) {
      updatedDay = updatedDay.copyWith(customerIds: _generatePseudoRandomDoctors());
    }

    _currentPlan!.weeks[0].days[dayIndex] = updatedDay;
    _safeNotifyListeners();
    StorageService.instance.saveTourPlan(_currentPlan!);
  }

  void updateFieldWorkSelection(int dayIndex, String brickId, List<String> customerIds) {
    if (_currentPlan == null || _currentPlan!.weeks.isEmpty) return;

    final currentDay = _currentPlan!.weeks[0].days[dayIndex];
    final updatedDay = currentDay.copyWith(
      type: DailyTourPlanType.field,
      brickId: brickId,
      customerIds: customerIds,
      isConfigured: true,
    );

    _currentPlan!.weeks[0].days[dayIndex] = updatedDay;
    _safeNotifyListeners();
    StorageService.instance.saveTourPlan(_currentPlan!);
  }

  void updateDailyPlan(int dayIndex, DailyTourPlanType type, String? brickId, List<String> customerIds) {
    if (_currentPlan == null || _currentPlan!.weeks.isEmpty) return;

    final currentDay = _currentPlan!.weeks[0].days[dayIndex];
    final updatedDay = currentDay.copyWith(
      type: type,
      brickId: type == DailyTourPlanType.field ? brickId : null,
      customerIds: type == DailyTourPlanType.field
          ? customerIds
          : (type == DailyTourPlanType.remote ? (customerIds.isNotEmpty ? customerIds : _generatePseudoRandomDoctors()) : []),
      isConfigured: true,
    );

    _currentPlan!.weeks[0].days[dayIndex] = updatedDay;
    _safeNotifyListeners();
    StorageService.instance.saveTourPlan(_currentPlan!);

    // Log Activity
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[dayIndex % 7];
    final dateStr = '${currentDay.date.day}/${currentDay.date.month}';
    final typeStr = type.name.toUpperCase();
    ActivityManager.instance.logActivity(
      type: 'tour_plan_edited',
      title: 'Updated Tour Plan',
      subtitle: '$dayName ($dateStr) • $typeStr Work',
    );
  }

  void clearDayConfig(int dayIndex) {
    if (_currentPlan == null || _currentPlan!.weeks.isEmpty) return;

    final currentDay = _currentPlan!.weeks[0].days[dayIndex];
    final updatedDay = currentDay.copyWith(
      type: DailyTourPlanType.off,
      brickId: null,
      customerIds: [],
      isConfigured: false,
    );

    _currentPlan!.weeks[0].days[dayIndex] = updatedDay;
    _safeNotifyListeners();
    StorageService.instance.saveTourPlan(_currentPlan!);
  }

  List<String> _generatePseudoRandomDoctors() {
    // Select a random brick, get some random doctors from it.
    if (allBricks.isEmpty) return ['Doc A', 'Doc B', 'Doc C']; // fallback
    
    final r = Random();
    final randomBrick = allBricks[r.nextInt(allBricks.length)];
    final brickId = randomBrick['brick_id'].toString();
    
    final docs = customersByBrick[brickId] ?? [];
    if (docs.isEmpty) return ['Doc A', 'Doc B', 'Doc C'];

    final shuffled = List<Map<String, dynamic>>.from(docs)..shuffle(r);
    final count = min(5, shuffled.length); // Pick up to 5
    return shuffled.take(count).map((e) => e['customer_id'].toString()).toList();
  }

  bool isWeek1Complete() {
    if (_currentPlan == null || _currentPlan!.weeks.isEmpty) return false;
    for (var day in _currentPlan!.weeks[0].days) {
      if (!day.isConfigured) return false;
      if (day.type == DailyTourPlanType.field) {
        if (day.brickId == null || day.customerIds.isEmpty) return false;
      }
    }
    return true;
  }

  void confirmAndCopyWeek() {
    if (_currentPlan == null || _currentPlan!.weeks.isEmpty) return;
    
    final week1 = _currentPlan!.weeks[0];
    List<WeeklyTourPlan> newWeeks = [week1];

    for (int w = 1; w < 4; w++) {
      List<DailyTourPlan> copiedDays = [];
      for (int d = 0; d < 7; d++) {
        final originalDay = week1.days[d];
        copiedDays.add(originalDay.copyWith(
          date: originalDay.date.add(Duration(days: 7 * w)),
        ));
      }
      newWeeks.add(WeeklyTourPlan(days: copiedDays));
    }

    _currentPlan = MonthlyTourPlan(
      status: _currentPlan!.status, // remains draft until submitted
      weeks: newWeeks,
    );
    
    StorageService.instance.saveTourPlan(_currentPlan!);
    _safeNotifyListeners();
  }

  void submitToManager() {
    if (_currentPlan == null) return;
    
    _currentPlan = MonthlyTourPlan(
      status: TourPlanStatus.pending,
      weeks: _currentPlan!.weeks,
    );
    
    StorageService.instance.saveTourPlan(_currentPlan!);
    _safeNotifyListeners();

    ActivityManager.instance.logActivity(
      type: 'tour_plan_created',
      title: 'Submitted Tour Plan',
      subtitle: 'Monthly Tour Plan sent to manager',
    );
  }

  void resetToDraft() {
    if (_currentPlan == null) return;
    
    _currentPlan = MonthlyTourPlan(
      status: TourPlanStatus.draft,
      weeks: [_currentPlan!.weeks[0]],
    );
    StorageService.instance.saveTourPlan(_currentPlan!);
    _safeNotifyListeners();
  }
}
