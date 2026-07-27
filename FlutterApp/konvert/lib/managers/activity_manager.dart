import 'package:flutter/foundation.dart';
import '../models/user_activity.dart';
import '../services/storage_service.dart';

class ActivityManager extends ChangeNotifier {
  static final ActivityManager _instance = ActivityManager._internal();
  static ActivityManager get instance => _instance;

  ActivityManager._internal() {
    _loadActivities();
  }

  List<UserActivity> _activities = [];

  List<UserActivity> get activities => List.unmodifiable(_activities);

  List<UserActivity> getRecentActivities({int limit = 5}) {
    if (_activities.length <= limit) {
      return List.unmodifiable(_activities);
    }
    return List.unmodifiable(_activities.sublist(0, limit));
  }

  void _loadActivities() {
    try {
      final rawList = StorageService.instance.getUserActivities();
      _activities = rawList
          .map((item) => UserActivity.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
      // Ensure sorted by newest first
      _activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error loading user activities: $e');
      _activities = [];
    }
  }

  Future<void> logActivity({
    required String type,
    required String title,
    required String subtitle,
  }) async {
    final newActivity = UserActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      subtitle: subtitle,
      timestamp: DateTime.now(),
    );

    // Insert at beginning (newest first)
    _activities.insert(0, newActivity);

    // Limit stored history to max 100 entries
    if (_activities.length > 100) {
      _activities = _activities.sublist(0, 100);
    }

    notifyListeners();

    // Persist to StorageService
    final serializable = _activities.map((a) => a.toMap()).toList();
    await StorageService.instance.setUserActivities(serializable);
  }

  Future<void> clearActivities() async {
    _activities.clear();
    notifyListeners();
    await StorageService.instance.setUserActivities([]);
  }
}
