class User {
  final String id;
  final String name;
  final String email;
  late final String password;
  final int role;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.avatar,
  });

  // Tạo từ JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 1,
      avatar: json['avatar'] ?? '',
    );
  }

  // Chuyển về JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'avatar': avatar,
    };
  }
}
