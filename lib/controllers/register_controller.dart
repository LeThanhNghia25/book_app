import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Hàm đăng ký người dùng
  Future<bool> registerUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required BuildContext context,
  }) async {
    // Kiểm tra các điều kiện nhập liệu
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty) {
      _showSnackbar(context, "Vui lòng nhập đầy đủ thông tin!");
      return false;
    }

    if (!_isEmailValid(email)) {
      _showSnackbar(context, "Email không hợp lệ!");
      return false;
    }

    if (password != confirmPassword) {
      _showSnackbar(context, "Mật khẩu và xác nhận mật khẩu không khớp!");
      return false;
    }

    try {
      // Đăng ký người dùng mới với Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy thông tin người dùng từ Firebase Authentication
      User? user = userCredential.user;

      if (user != null) {
        // Lấy reference của node Users
        DatabaseReference usersRef = _database.ref('Users');

        // Lấy số lượng người dùng hiện tại để tính ID tiếp theo bằng phương thức get()
        DataSnapshot snapshot = (await usersRef.get());

        int userCount = snapshot.exists ? snapshot.children.length : 0;
        String newUserId = 'user${userCount + 1}';  // Tạo ID cho người dùng mới (user1, user2, ...)

        // Lưu thông tin người dùng vào Firebase Realtime Database với ID tự tạo
        final newUserRef = usersRef.child(newUserId);  // Lưu thông tin dưới dạng userId

        await newUserRef.set({
          'userId': newUserId,  // Lưu userId được tự động tạo
          'email': email,
          'name': name,  // Lưu tên vào Firebase
          'role': 'user',  // Vai trò người dùng
          'avatar': 'https://i.imgur.com/mOFr66N.png',  // Avatar mặc định
          'createdAt': DateTime.now().toIso8601String(), // Thêm thời gian tạo tài khoản
        });

        _showSnackbar(context, "Đăng ký thành công!");
        return true;
      } else {
        _showSnackbar(context, "Đăng ký thất bại!");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi đăng ký
      String message = 'Đăng ký thất bại';
      if (e.code == 'email-already-in-use') {
        message = 'Email đã tồn tại!';
      }
      _showSnackbar(context, message);
      return false;
    }
  }

  // Hàm kiểm tra tính hợp lệ của email
  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  // Hàm hiển thị thông báo Snackbar
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
