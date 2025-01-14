import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/login_screen.dart';

class UserController {
  final DatabaseReference _userRef;

  UserController(FirebaseDatabase database)
      : _userRef = database.ref().child('Users');

  /// Lấy thông tin người dùng hiện tại từ Firebase Authentication
  firebase_auth.User? getCurrentUser() {
    return firebase_auth.FirebaseAuth.instance.currentUser;
  }

  /// Lấy thông tin user từ Firebase Realtime Database dựa trên người dùng hiện tại
  Future<User?> fetchCurrentUserData() async {
    final currentUser = getCurrentUser();
    if (currentUser == null) {
      return null; // Nếu chưa đăng nhập, trả về null
    }

    final snapshot = await _userRef.child(currentUser.uid).get();
    if (snapshot.exists) {
      var userData = Map<String, dynamic>.from(snapshot.value as Map);
      userData['id'] = currentUser.uid; // Gắn UID của user vào object
      return User.fromJson(userData);
    }

    return null; // Không tìm thấy thông tin người dùng trong database
  }

  /// Lấy danh sách tất cả user từ Firebase
  Future<List<User>> fetchUsers() async {
    final snapshot = await _userRef.get();
    if (snapshot.exists && snapshot.value is Map) {
      final usersMap = snapshot.value as Map<dynamic, dynamic>;
      return usersMap.entries.map((entry) {
        var userData = Map<String, dynamic>.from(entry.value);
        userData['id'] = entry.key; // Gán id từ key của Map vào User
        return User.fromJson(userData);
      }).toList();
    }
    return [];
  }

  /// Lấy thông tin user mặc định (ví dụ user1)
  Future<User?> fetchDefaultUser() async {
    final snapshot = await _userRef.child('user1').get();
    if (snapshot.exists) {
      var userData = Map<String, dynamic>.from(snapshot.value as Map);
      userData['id'] = 'user1';
      return User.fromJson(userData);
    }
    return null;
  }

  /// Lấy thông tin chi tiết 1 user theo id
  Future<User?> fetchUserById(String userId) async {
    final snapshot = await _userRef.child(userId).get();
    if (snapshot.exists) {
      var userData = Map<String, dynamic>.from(snapshot.value as Map);
      userData['id'] = userId;
      return User.fromJson(userData);
    }
    return null;
  }

  /// Lấy thông tin chi tiết 1 user theo email
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

  /// Hàm đăng xuất
  Future<void> logout(BuildContext context) async {
    await firebase_auth.FirebaseAuth.instance.signOut(); // Đăng xuất khỏi Firebase Authentication
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  /// Cập nhật thông tin người dùng
  Future<void> updateUser(String userId, Map<String, dynamic> updatedData) async {
    await _userRef.child(userId).update(updatedData);
  }
}
