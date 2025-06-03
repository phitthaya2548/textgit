class Profile {
  final int id;
  final String name;
  final String email;
  final String role;
  final String profilePicture; // เพิ่มตรงนี้
  final String phone;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.profilePicture, // เพิ่มตรงนี้
    this.phone = '',
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      profilePicture: json['profile_picture'] ?? '', // map JSON key
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_picture': profilePicture, // export เป็น JSON
      'phone': phone,
    };
  }

  Profile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profilePicture,
    S
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      
    );
  }
}
