import 'package:book_app/screens/profileEdit_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';

class UserScreen extends ConsumerStatefulWidget {
  final User? user;  // Nhận thông tin người dùng từ BaseScreen
  const UserScreen({super.key,this.user});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();

    // Kiểm tra xem có user từ widget.user không, nếu có thì không cần fetch lại từ Firebase
    if (widget.user != null) {
      _userFuture = Future.value(widget.user); // Đặt user đã truyền vào làm giá trị của Future
    } else {
      final database = FirebaseDatabase.instanceFor(app: Firebase.app());
      final userController = UserController(database);
      _userFuture = userController.fetchCurrentUserData(); // Fetch lại nếu không có user
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
                // Thu thập dữ liệu từ các TextField
                final updatedData = {
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'password': passwordController.text.trim(),
                  'avatar': avatarController.text.trim(),
                };

                try {
                  // Cập nhật thông tin người dùng lên Firebase
                  final database = FirebaseDatabase.instanceFor(app: Firebase.app());
                  final userController = UserController(database);
                  await userController.updateUser(user.id, updatedData);

                  // Cập nhật lại Future để màn hình chính tự làm mới
                  setState(() {
                    _userFuture = userController.fetchCurrentUserData();
                  });

                  // Đóng hộp thoại
                  Navigator.pop(context);

                  // Hiển thị thông báo thành công (không bắt buộc)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cập nhật thông tin thành công!')),
                  );
                } catch (e) {
                  // Xử lý lỗi nếu cập nhật thất bại
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cập nhật thất bại: $e')),
                  );
                }
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
      backgroundColor: const Color(0xffffffff),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            User user = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(12),
              physics: const BouncingScrollPhysics(),
              children: [
                Container(height: 35),
                userTile(user),
                divider(),
                colorTiles(user),
                divider(),
                bwTitles(context), // Truyền context vào bwTitles
              ],
            );
          } else {
            return const Center(child: Text('No user data available.'));
          }
        },
      ),
    );
  }

  // Hiển thị thông tin user từ Firebase
  Widget userTile(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.avatar),
        onBackgroundImageError: (_, __) {
          // Hiển thị ảnh mặc định nếu ảnh không tải được
        },
      ),
      title: Txt(
        text: user.name,
        fontWeight: FontWeight.bold,
      ),
      subtitle: Txt(text: user.email),
    );
  }

  Widget divider() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Divider(
        thickness: 1.5,
      ),
    );
  }

  Widget colorTiles(User user) {
    return Column(
      children: [
        colorTile(Icons.person_outline, Colors.deepPurple, "Chỉnh sửa thông tin người dùng",
            onTap: () => _showEditUserDialog(context,user )), // Sửa tại đây
        colorTile(Icons.settings_outlined, Colors.blue, "Cài đặt"),
        colorTile(Icons.bookmark_border, Colors.pink, "Lưu bài viết"),
        colorTile(Icons.favorite_border, Colors.orange, "Referral code"),
      ],
    );
  }

  Widget bwTitles(BuildContext context) {
    return Column(
      children: [
        bwTitle(Icons.info_outline, "Đăng xuất", onTap: () => logout(context)),
        bwTitle(Icons.border_color_outlined, "HandBook"),
        bwTitle(Icons.textsms_outlined, "Community"),
      ],
    );
  }

  Widget bwTitle(IconData icon, String text, {void Function()? onTap}) {
    return colorTile(icon, Colors.black, text, blackAndWhite: true, onTap: onTap);
  }

  Widget colorTile(IconData icon, Color color, String text,
      {bool blackAndWhite = false, void Function()? onTap}) {
    return ListTile(
      leading: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: blackAndWhite ? const Color(0xfff3f4fe) : color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: color),
      ),
      title: Txt(
        text: text,
        fontWeight: FontWeight.w500,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
      onTap: onTap, // Chuyển onTap vào đây
    );
  }

  Widget Txt({required String text, FontWeight? fontWeight}) {
    return Text(
      text,
      style: TextStyle(fontWeight: fontWeight ?? FontWeight.normal),
    );
  }

  void logout(BuildContext context) {
    final userController = UserController(FirebaseDatabase.instanceFor(app: Firebase.app()));
    userController.logout(context); // Gọi phương thức logout từ UserController
  }
}
