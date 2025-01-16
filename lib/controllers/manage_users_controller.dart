import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart';

class ManageUsersController {
  final DatabaseReference _userRef;

  ManageUsersController(FirebaseDatabase database)
      : _userRef = database.ref('Users');

  /// Lấy tất cả người dùng từ Firebase
  Future<List<User>> fetchAllUsers() async {
    try {
      final snapshot = await _userRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        final usersMap = Map<String, dynamic>.from(snapshot.value as Map);

        // Chuyển đổi dữ liệu từ Firebase sang danh sách User
        return usersMap.entries.map((entry) {
          final userId = entry.key;
          final userData = Map<String, dynamic>.from(entry.value);
          return User.fromJson(userId, userData);
        }).toList();
      }
      return [];
    } catch (e) {
      print('Lỗi khi lấy danh sách người dùng: $e');
      return [];
    }
  }

  /// Xóa người dùng
  Future<void> deleteUser(String userId) async {
    try {
      await _userRef.child(userId).remove();
    } catch (e) {
      print('Lỗi khi xóa người dùng: $e');
    }
  }

  /// Cập nhật thông tin người dùng
  Future<void> updateUser(String userId, Map<String, dynamic> updatedData) async {
    try {
      await _userRef.child(userId).update(updatedData);
    } catch (e) {
      print('Lỗi khi cập nhật thông tin người dùng: $e');
    }
  }

  /// Thêm người dùng mới
  Future<void> addUser(User user) async {
    try {
      await _userRef.child(user.id).set(user.toJson());
    } catch (e) {
      print('Lỗi khi thêm người dùng mới: $e');
    }
  }
}