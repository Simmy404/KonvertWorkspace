import 'dart:convert';

enum NotificationType { normal, request, important }

class AppNotification {
  final String id;
  final String title;
  final List<String> body;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    List<String>? body,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] is String
          ? [map['body']]
          : List<String>.from(map['body'] ?? []),
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.normal,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppNotification.fromJson(String source) =>
      AppNotification.fromMap(json.decode(source));
}
