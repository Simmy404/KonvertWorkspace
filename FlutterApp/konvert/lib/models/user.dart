// lib/models/user.dart
class User {
  final int id;
  final String name;
  final int bid;
  final String category;
  final bool isOnline;
  final String googleApi;
  final String username;

  const User({
    required this.id,
    required this.name,
    required this.bid,
    required this.category,
    required this.isOnline,
    required this.googleApi,
    required this.username,
  });

  // Factory constructor to safely parse from the API JSON response
  factory User.fromJson(Map<String, dynamic> json, String username) {
    return User(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      bid: int.tryParse(json['bid']?.toString() ?? '0') ?? 0,
      category: json['category']?.toString() ?? '',
      isOnline: json['isOnline']?.toString().toLowerCase() == 'online',
      googleApi: json['GoogleAPI']?.toString() ?? '',
      username: username,
    );
  }

  // Convert to map for local storage encoding
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bid': bid,
      'category': category,
      'isOnline': isOnline,
      'googleApi': googleApi,
      'username': username,
    };
  }
}