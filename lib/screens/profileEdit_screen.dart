import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/user.dart';
import '../controllers/user_controller.dart';

class ProfileEditScreen extends StatefulWidget {
  final User? user; // Nhận người dùng từ UserScreen
  const ProfileEditScreen({super.key, this.user});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final UserController _usersController;
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();

    // Khởi tạo UserController
    final database = FirebaseDatabase.instanceFor(app: Firebase.app());
    _usersController = UserController(database);

    // Lấy dữ liệu người dùng từ Firebase hoặc từ đối tượng user đã truyền vào
    if (widget.user != null) {
      _userFuture = Future.value(widget.user);  // Nếu đã có user được truyền vào
    } else {
      _userFuture = _usersController.fetchCurrentUserData(); // Lấy dữ liệu user từ Firebase nếu không có
    }
  }

  // Hàm hiển thị hộp thoại chỉnh sửa thông tin người dùng
  void _showEditUserDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController(text: ''); // Khởi tạo mật khẩu trống
    final avatarController = TextEditingController(text: user.avatar);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa người dùng'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu'),
                  obscureText: true,
                ),
                TextField(
                  controller: avatarController,
                  decoration: const InputDecoration(labelText: 'URL Avatar'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại mà không lưu thay đổi
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'password': passwordController.text.trim(),
                  'avatar': avatarController.text.trim(),
                };

                // Cập nhật thông tin người dùng lên Firebase
                await _usersController.updateUser(user.id, updatedData);
                setState(() {
                  // Tải lại dữ liệu người dùng
                  _userFuture = _usersController.fetchCurrentUserData();
                });
                Navigator.pop(context); // Đóng hộp thoại sau khi lưu
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Chỉnh sửa thông tin người dùng',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Không tìm thấy người dùng.'));
          } else {
            final user = snapshot.data!;
            return ListView(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatar),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditUserDialog(context, user),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
