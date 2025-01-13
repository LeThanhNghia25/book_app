import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart';

class ManageUsersController {
  final DatabaseReference _userRef;

  ManageUsersController(FirebaseDatabase database)
      : _userRef = database.ref('Users');

  // Lấy tất cả người dùng từ Firebase
  Future<List<User>> fetchAllUsers() async {
    final snapshot = await _userRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final usersMap = snapshot.value as Map<dynamic, dynamic>;

      // Chuyển đổi dữ liệu từ Firebase sang danh sách User
      return usersMap.entries.map((entry) {
        final userId = entry.key.toString();
        final userData = entry.value as Map<dynamic, dynamic>;
        return User.fromJson({...userData, 'id': userId});
      }).toList();
    } else {
      return [];
    }
  }

  // Xóa người dùng
  Future<void> deleteUser(String userId) async {
    await _userRef.child(userId).remove();
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUser(String userId, Map<String, dynamic> updatedData) async {
    await _userRef.child(userId).update(updatedData);
  }

  // Thêm người dùng mới
  Future<void> addUser(User user) async {
    await _userRef.child(user.id).set(user.toJson());
  }
}
