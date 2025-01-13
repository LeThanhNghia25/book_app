import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controllers/user_controller.dart';
import '../models/user.dart';

class ProfileEditScreen extends StatefulWidget {
  final User user;

  const ProfileEditScreen({super.key, required this.user});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller cho các trường nhập liệu
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController(text: '');  // Để trống khi chỉnh sửa password
  }

  @override
  void dispose() {
    // Giải phóng các controller khi không sử dụng nữa
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = User(
        id: widget.user.id,
        name: _nameController.text,
        email: _emailController.text,
        avatar: widget.user.avatar,  // Giữ nguyên avatar nếu không thay đổi
        password: widget.user.password, // Mặc định lấy password hiện tại
        role: widget.user.role, // Mặc định giữ nguyên role
      );

      if (_passwordController.text.isNotEmpty) {
        // Cập nhật mật khẩu nếu có thay đổi
        updatedUser.password = _passwordController.text;
      }

      final userController = UserController(FirebaseDatabase.instanceFor(app: Firebase.app()));
      // await userController.updateUser(updatedUser);

      // Quay lại trang user_screen sau khi cập nhật thành công
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa thông tin cá nhân"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu (nếu thay đổi)'),
                validator: (value) {
                  if (value != null && value.length < 4) {
                    return 'Mật khẩu phải có ít nhất 4 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: const Text('Lưu thông tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
