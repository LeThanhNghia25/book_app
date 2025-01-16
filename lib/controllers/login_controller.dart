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
        final usersMap = Map<String, dynamic>.from(userSnapshot.value as Map);

        // Duyệt qua tất cả người dùng để kiểm tra thông tin đăng nhập
        for (var entry in usersMap.entries) {
          final userId = entry.key;
          final userData = Map<String, dynamic>.from(entry.value);

          // Kiểm tra email và mật khẩu
          if (userData['email'] == email && userData['password'] == password) {
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
        final usersMap = Map<String, dynamic>.from(userSnapshot.value as Map);

        // Duyệt qua tất cả người dùng để tìm thông tin người dùng khớp với email
        for (var entry in usersMap.entries) {
          final userId = entry.key;
          final userData = Map<String, dynamic>.from(entry.value);

          if (userData['email'] == email) {
            // Trả về đối tượng User
            return User.fromJson(userId, userData);
          }
        }
      }

      return null; // Trả về null nếu không tìm thấy người dùng
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  /// Hàm lấy danh sách toàn bộ người dùng
  Future<List<User>> fetchAllUsers() async {
    final usersRef = _database.ref('Users');

    try {
      final userSnapshot = await usersRef.get();

      if (userSnapshot.exists) {
        // Chuyển dữ liệu từ snapshot thành Map
        final usersMap = Map<String, dynamic>.from(userSnapshot.value as Map);

        // Tạo danh sách User từ Map
        return usersMap.entries.map((entry) {
          final userId = entry.key;
          final userData = Map<String, dynamic>.from(entry.value);
          return User.fromJson(userId, userData);
        }).toList();
      }

      return []; // Trả về danh sách rỗng nếu không có dữ liệu
    } catch (e) {
      print('Lỗi khi lấy danh sách người dùng: $e');
      return [];
    }
  }
}