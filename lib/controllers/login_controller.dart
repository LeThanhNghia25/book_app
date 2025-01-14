import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/src/widgets/framework.dart';

class LoginController {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Hàm đăng nhập
  Future<int?> login(String email, String password) async {
    final usersRef = _database.ref('Users');

    try {
      final userSnapshot = await usersRef.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> users = Map.from(userSnapshot.value as Map);

        for (var userId in users.keys) {
          final user = users[userId];

          if (user['email'] == email && user['password'] == password) {
            // Kiểm tra role hợp lệ
            if (user.containsKey('role')) {
              return user['role']; // Trả về vai trò của người dùng (0 hoặc 1)
            } else {
              return null; // Không tìm thấy role
            }
          }
        }
      }

      return null; // Không tìm thấy người dùng hoặc thông tin không hợp lệ
    } catch (e) {
      print('Lỗi khi đăng nhập: $e');
      return null; // Lỗi trong quá trình xử lý
    }
  }

  // Hàm lấy thông tin người dùng sau khi đăng nhập thành công
  Future<Map<String, dynamic>?> getUserInfo(String email) async {
    final usersRef = _database.ref('Users');

    try {
      final userSnapshot = await usersRef.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> users = Map.from(userSnapshot.value as Map);

        // Duyệt qua tất cả người dùng để lấy thông tin của người dùng
        for (var userId in users.keys) {
          final user = users[userId];

          if (user['email'] == email) {
            return user; // Trả về thông tin người dùng
          }
        }
      }
      return null; // Không tìm thấy người dùng
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

}
