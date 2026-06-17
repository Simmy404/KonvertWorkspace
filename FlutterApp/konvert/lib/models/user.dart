// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String bid;
  final String category;
  final bool isOnline;
  final String googleApi;
  final String username;
  final String? email;
  final String? phone;
  final String? role;
  final DateTime? lastLogin;
  final bool isLoggedIn;
  
  User({
    required this.id,
    required this.name,
    required this.bid,
    required this.category,
    required this.isOnline,
    required this.googleApi,
    required this.username,
    this.email,
    this.phone,
    this.role,
    this.lastLogin,
    this.isLoggedIn = false,
  });
  
  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      bid: json['bid']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      isOnline: json['isOnline']?.toString().toLowerCase() == 'online',
      googleApi: json['GoogleAPI']?.toString() ?? '',
      username: json['username']?.toString() ?? json['email']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.tryParse(json['lastLogin'].toString()) 
          : null,
      isLoggedIn: json['isLoggedIn'] == true,
    );
  }
  
  // Convert User to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bid': bid,
      'category': category,
      'isOnline': isOnline ? 'online' : 'offline',
      'GoogleAPI': googleApi,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'lastLogin': lastLogin?.toIso8601String(),
      'isLoggedIn': isLoggedIn,
    };
  }
  
  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? bid,
    String? category,
    bool? isOnline,
    String? googleApi,
    String? username,
    String? email,
    String? phone,
    String? role,
    DateTime? lastLogin,
    bool? isLoggedIn,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      bid: bid ?? this.bid,
      category: category ?? this.category,
      isOnline: isOnline ?? this.isOnline,
      googleApi: googleApi ?? this.googleApi,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
  
  // Create a logged in version of the user
  User withLogin() {
    return copyWith(
      isLoggedIn: true,
      lastLogin: DateTime.now(),
    );
  }
  
  // Create a logged out version of the user
  User withoutLogin() {
    return copyWith(isLoggedIn: false);
  }
  
  @override
  String toString() {
    return 'User(id: $id, name: $name, bid: $bid, category: $category, isOnline: $isOnline, isLoggedIn: $isLoggedIn, username: $username)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}