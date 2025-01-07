import 'package:firebase_database/firebase_database.dart';

class LoginController {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Hàm đăng nhập
  Future<bool> login(String email, String password) async {
    // Truy vấn dữ liệu người dùng từ Firebase
    final usersRef = _database.ref('Users');

    try {
      // Lấy dữ liệu người dùng theo email
      final userSnapshot = await usersRef.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> users = Map.from(userSnapshot.value as Map);

        // Duyệt qua tất cả người dùng để kiểm tra thông tin đăng nhập
        for (var userId in users.keys) {
          final user = users[userId];

          // Kiểm tra email và mật khẩu
          if (user['email'] == email && user['password'] == password) {
            // Đăng nhập thành công
            return true;
          }
        }
      }

      // Nếu không tìm thấy thông tin đăng nhập hợp lệ
      return false;
    } catch (e) {
      print('Lỗi khi đăng nhập: $e');
      return false;
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
