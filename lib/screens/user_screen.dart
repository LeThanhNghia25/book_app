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
                colorTiles(),
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

  Widget colorTiles() {
    return Column(
      children: [
        colorTile(Icons.person_outline, Colors.deepPurple, "Chỉnh sửa thông tin người dùng",
            onTap: () => _navigateToProfileEditScreen(context)),
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

  void _navigateToProfileEditScreen(BuildContext context) {
    final userController = UserController(FirebaseDatabase.instanceFor(app: Firebase.app()));

    _userFuture.then((user) {
      if (user != null) {
        // Điều hướng đến màn hình chỉnh sửa, truyền dữ liệu người dùng qua constructor.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileEditScreen(user: user), // Truyền user vào màn hình chỉnh sửa
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user data available.')),
        );
      }
    });
  }
}
