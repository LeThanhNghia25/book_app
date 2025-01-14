import 'package:firebase_database/firebase_database.dart';

import '../models/user.dart';

class LoginController {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Hàm đăng nhập
  Future<bool> login(String email, String password) async {
    final usersRef = _database.ref('Users');

    try {
      // Lấy toàn bộ dữ liệu người dùng từ Firebase
      final userSnapshot = await usersRef.get();

      if (userSnapshot.exists) {
        // Chuyển dữ liệu từ snapshot thành Map
        Map<String, dynamic> users = Map.from(userSnapshot.value as Map);

        // Duyệt qua tất cả người dùng để kiểm tra thông tin đăng nhập
        for (var userId in users.keys) {
          final user = users[userId];

          // Kiểm tra email và mật khẩu
          if (user['email'] == email && user['password'] == password) {
            return true; // Đăng nhập thành công
          }
        }
      }

      return false; // Thông tin đăng nhập không hợp lệ
    } catch (e) {
      print('Lỗi khi đăng nhập: $e');
      return false; // Trả về false khi xảy ra lỗi
    }
  }

  /// Hàm lấy thông tin người dùng sau khi đăng nhập thành công
  Future<User?> getUserInfo(String email) async {
    final usersRef = _database.ref('Users');

    try {
      // Lấy toàn bộ dữ liệu người dùng từ Firebase
      final userSnapshot = await usersRef.get();

      if (userSnapshot.exists) {
        // Chuyển dữ liệu từ snapshot thành Map
        Map<String, dynamic> users = Map.from(userSnapshot.value as Map);

        // Duyệt qua tất cả người dùng để tìm thông tin người dùng khớp với email
        for (var userId in users.keys) {
          final user = users[userId];

          if (user['email'] == email) {
            // Trả về đối tượng User thay vì Map
            return User.fromJson({
              'id': userId, // Gán id người dùng
              ...Map<String, dynamic>.from(user), // Kết hợp dữ liệu từ user
            });
          }
        }
      }

      return null; // Trả về null nếu không tìm thấy người dùng
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

}
