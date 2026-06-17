// lib/models/domain.dart
class Domain {
  final String name;
  final String url;
  final String apiKey;

  Domain({
    required this.name,
    required this.url,
    required this.apiKey,
  });

  // Create Domain from Map (for storage)
  factory Domain.fromMap(Map<String, dynamic> map) {
    return Domain(
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      apiKey: map['apiKey'] ?? '',
    );
  }

  // Convert Domain to Map (for storage)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'apiKey': apiKey,
    };
  }

  // Copy with method for updates
  Domain copyWith({
    String? name,
    String? url,
    String? apiKey,
  }) {
    return Domain(
      name: name ?? this.name,
      url: url ?? this.url,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  String toString() => name;
}