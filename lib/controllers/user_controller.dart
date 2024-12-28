import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart';

class UserController {
  final DatabaseReference _userRef;

  UserController(FirebaseDatabase database)
      : _userRef = database.ref().child('Users');

  // Lấy danh sách tất cả user.dart từ Firebase
  Future<List<User>> fetchUsers() async {
    final snapshot = await _userRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final usersMap = snapshot.value as Map<dynamic, dynamic>;

      // Chuyển đổi từ Map sang List<User>
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

  // Lấy thông tin chi tiết 1 user.dart theo id
  Future<User?> fetchUserById(String userId) async {
    final snapshot = await _userRef.child(userId).get();
    if (snapshot.exists) {
      var userData = Map<String, dynamic>.from(snapshot.value as Map);
      return User.fromJson(userData);
    }
    return null;
  }
}
