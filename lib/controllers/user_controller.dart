import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/login_screen.dart';

class UserController {
  final DatabaseReference _userRef;

  UserController(FirebaseDatabase database)
      : _userRef = database.ref().child('Users');

  // Lấy thông tin người dùng hiện tại từ Firebase Authentication
  firebase_auth.User? getCurrentUser() {
    return firebase_auth.FirebaseAuth.instance.currentUser;
  }

  // Lấy thông tin user từ Firebase Realtime Database dựa trên người dùng hiện tại
  Future<User?> fetchCurrentUserData() async {
    final currentUser = getCurrentUser();
    if (currentUser == null) {
      print("No logged-in user after update."); // Debug print
      return null;
    }

    print("Fetching data for UID: ${currentUser.uid}"); // Debug print
    final snapshot = await _userRef.child(currentUser.uid).get();
    if (snapshot.exists) {
      var userData = Map<String, dynamic>.from(snapshot.value as Map);
      userData['id'] = currentUser.uid;
      print("Fetched user data: $userData"); // Debug print
      return User.fromJson(userData);
    }

    print("No data found for UID: ${currentUser.uid}"); // Debug print
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

  // Hàm đăng xuất
  Future<void> logout(BuildContext context) async {
    await firebase_auth.FirebaseAuth.instance.signOut(); // Đăng xuất khỏi Firebase Authentication
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Cập nhật thông tin người dùng
  Future<User?> updateUser(String userId, Map<String, dynamic> updatedData) async {
    try {
      // Cập nhật thông tin người dùng trong Firebase
      await _userRef.child(userId).update(updatedData);
      print("Updated user data: $updatedData"); // Debug print

      // Sau khi cập nhật, lấy lại thông tin người dùng
      final updatedUser = await fetchUserById(userId);
      if (updatedUser != null) {
        print("Fetched updated user: $updatedUser"); // Debug print
        return updatedUser; // Trả về thông tin người dùng mới
      }
      return null;
    } catch (e) {
      throw Exception("Failed to update user data: $e");
    }
  }
}
