import 'dart:convert';

class UserActivity {
  final String id;
  final String type; // 'booking_created', 'booking_edited', 'booking_deleted', 'tour_plan_created', 'tour_plan_edited'
  final String title;
  final String subtitle;
  final DateTime timestamp;

  UserActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory UserActivity.fromMap(Map<String, dynamic> map) {
    return UserActivity(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: map['type']?.toString() ?? 'general',
      title: map['title']?.toString() ?? 'Activity',
      subtitle: map['subtitle']?.toString() ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserActivity.fromJson(String source) =>
      UserActivity.fromMap(json.decode(source) as Map<String, dynamic>);

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return '${timestamp.day} ${_monthName(timestamp.month)} ${timestamp.year}';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
