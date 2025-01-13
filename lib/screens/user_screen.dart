import 'package:book_app/screens/profileEdit_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';
import 'login_screen.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  late Future<User?> _userFuture;
  late String userId;


  @override
  void initState() {
    super.initState();
    userId = "someUserId"; // Thay thế với userId thật
    final database = FirebaseDatabase.instanceFor(app: Firebase.app());
    final userController = UserController(database);
    _userFuture = userController.fetchUserById(userId);

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
                const SizedBox(height: 35),
                userTile(user),
                divider(),
                colorTiles(),
                divider(),
                bwTitles(),
              ],
            );
          } else {
            return const Center(child: Text('No user data available.'));
          }
        },
      ),
    );
  }

  Widget userTile(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.avatar),
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

  Widget colorTiles() {
    return Column(
      children: [
        colorTile(Icons.person_outline, Colors.deepPurple, "Thông tin cá nhân", ),
        colorTile(Icons.settings_outlined, Colors.blue, "Cài đặt"),
        colorTile(Icons.credit_card, Colors.pink, "Payment"),
        colorTile(Icons.favorite_border, Colors.orange, "Referral code"),
      ],
    );
  }

  Widget bwTitles() {
    return Column(
      children: [
        bwTitle(Icons.info_outline, "Đăng xuất", onTap: _handleLogout),
        bwTitle(Icons.border_color_outlined, "HandBook"),
        bwTitle(Icons.textsms_outlined, "Community"),
      ],
    );
  }

  Widget bwTitle(IconData icon, String text, {VoidCallback? onTap}) {
    return colorTile(icon, Colors.black, text, blackAndWhite: true, onTap: onTap);
  }

  Widget colorTile(IconData icon, Color color, String text,
      {bool blackAndWhite = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
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
    );
  }

  Widget Txt({required String text, FontWeight? fontWeight}) {
    return Text(
      text,
      style: TextStyle(fontWeight: fontWeight ?? FontWeight.normal),
    );
  }

  Future<void> _handleLogout() async {
    final userController = UserController(FirebaseDatabase.instanceFor(app: Firebase.app()));

    // Xóa thông tin người dùng khỏi bộ nhớ hoặc trạng thái ứng dụng
    // Bạn có thể thêm bất kỳ phương thức nào ở đây, ví dụ: xóa thông tin tài khoản

    // Điều hướng về màn hình đăng nhập
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false, // Xóa toàn bộ stack
    );
  }
  // void _goToProfileEdit(User user) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ProfileEditScreen(user:user), // Chuyển User hiện tại
  //     ),
  //   );
  // }


}


