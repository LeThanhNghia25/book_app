import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class RegisterController {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Hàm đăng ký người dùng
  Future<bool> registerUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required BuildContext context,
  }) async {
    if (password.length < 6) {
      _showSnackbar(context, "Mật khẩu phải có ít nhất 6 ký tự!");
      return false;
    }

    try {
      // Đăng ký người dùng mới với Firebase Authentication
      print("Bắt đầu đăng ký người dùng...");
      auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Đăng ký thành công!");

      auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        DatabaseReference usersRef = _database.ref('Users');
        print("Kết nối Firebase Database thành công!");

        // Tạo ID tự tăng theo kiểu user1, user2, ...
        String newUserId = await _generateNewUserId(usersRef);
        print("Tạo ID mới: $newUserId");

        // Lưu người dùng vào Firebase Database
        final newUser = User(
          id: newUserId,
          name: name,
          email: email,
          password: password,
          role: 1, // Mặc định role là user
          avatar: 'https://i.imgur.com/mOFr66N.png',
        );

        await usersRef.child(newUserId).set(newUser.toJson());
        print("Lưu người dùng thành công: ${newUser.toJson()}");
        _showSnackbar(context, "Đăng ký thành công!");
        return true;
      } else {
        _showSnackbar(context, "Đăng ký thất bại!");
        return false;
      }
    } on auth.FirebaseAuthException catch (e) {
      print("Lỗi FirebaseAuthException: ${e.code}");
      if (e.code == 'email-already-in-use') {
        _showSnackbar(context, "Email đã được sử dụng!");
      } else if (e.code == 'weak-password') {
        _showSnackbar(context, "Mật khẩu quá yếu! Hãy sử dụng mật khẩu mạnh hơn.");
      } else {
        _showSnackbar(context, "Đăng ký thất bại! Lỗi: ${e.message}");
      }
      return false;
    }
  }

  // Hàm tạo ID tự động user1, user2, ...
  Future<String> _generateNewUserId(DatabaseReference usersRef) async {
    DataSnapshot snapshot = await usersRef.get();
    if (snapshot.exists) {
      final usersMap = snapshot.value as Map<dynamic, dynamic>;
      int maxId = 0;
      for (var key in usersMap.keys) {
        if (key.toString().startsWith("user")) {
          int currentId = int.tryParse(key.toString().substring(4)) ?? 0;
          maxId = currentId > maxId ? currentId : maxId;
        }
      }
      return 'user${maxId + 1}';
    } else {
      return 'user1';
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
