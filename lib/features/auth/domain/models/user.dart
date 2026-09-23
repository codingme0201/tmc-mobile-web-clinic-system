class AppUser {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final bool isProfileComplete;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.isProfileComplete = false,
  });

  AppUser copyWith({
    String? name,
    String? email,
    bool? isProfileComplete,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'isProfileComplete': isProfileComplete,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isProfileComplete: json['isProfileComplete'] == true,
    );
  }
}
