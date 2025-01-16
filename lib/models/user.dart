class User {
  final String id; // ID của user, sẽ được lấy từ key trong Firebase
  final String name;
  final String email;
  final String password;
  final int role; // 0: Admin, 1: User
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.avatar,
  });

  // Tạo từ JSON, cần truyền thêm `id` từ key của Firebase
  factory User.fromJson(String id, Map<String, dynamic> json) {
    return User(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 1,
      avatar: json['avatar'] ?? '',
    );
  }

  // Chuyển về JSON (không bao gồm `id`)
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
