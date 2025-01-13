import 'package:firebase_database/firebase_database.dart';

import '../models/user.dart';

class UserController {
  final DatabaseReference _userRef;

  UserController(FirebaseDatabase database)
      : _userRef = database.ref().child('Users');

  // Lấy danh sách tất cả user từ Firebase
  Future<List<User>> fetchUsers() async {
    final snapshot = await _userRef.get();
    if (snapshot.exists && snapshot.value is Map) {
      final usersMap = snapshot.value as Map<dynamic, dynamic>;
      return usersMap.entries.map((entry) {
        var userData = Map<String, dynamic>.from(entry.value);
        userData['id'] = entry.key;  // Gán id từ key của Map vào User
        return User.fromJson(userData);
      }).toList();
    }
    return [];
  }

  // Lấy thông tin user mặc định (ví dụ user1)
  Future<User?> fetchDefaultUser() async {
    final snapshot = await _userRef.child('user1').get();
    if (snapshot.exists) {
      var userData = Map<String, dynamic>.from(snapshot.value as Map);
      userData['id'] = 'user1';
      return User.fromJson(userData);
    }
    return null;
  }

  // Lấy thông tin chi tiết 1 user theo id
  Future<User?> fetchUserById(String userId) async {
    final snapshot = await _userRef.child(userId).get();
    if (snapshot.exists) {
      var userData = Map<String, dynamic>.from(snapshot.value as Map);
      userData['id'] = userId;
      return User.fromJson(userData );
    }
    return null;
  }

  // Lấy thông tin chi tiết 1 user theo email
  Future<User?> fetchUserByEmail(String email) async {
    final snapshot = await _userRef.orderByChild('email').equalTo(email).limitToFirst(1).get();
    if (snapshot.exists) {
      final usersMap = snapshot.value as Map<dynamic, dynamic>;
      final userKey = usersMap.keys.first;
      final userData = Map<String, dynamic>.from(usersMap[userKey]);
      userData['id'] = userKey;
      return User.fromJson(userData);
    }
    return null;
  }
  // // Phương thức cập nhật thông tin người dùng
  // Future<void> updateUser(User user) async {
  //   final userRef = _userRef.child(user.id);
  //   await userRef.update({
  //     'name': user.name,
  //     'email': user.email,
  //     'password': user.password, // Cập nhật mật khẩu nếu có thay đổi
  //     'role': user.role,         // Cập nhật role nếu cần thiết
  //     'avatar': user.avatar,     // Cập nhật avatar nếu có thay đổi
  //   });
  // }
}


