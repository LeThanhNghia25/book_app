import 'package:book_app/screens/saved_books_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';
import '../notifiers/theme_notifier.dart';

class UserScreen extends ConsumerStatefulWidget {
  final User? user; // Nhận thông tin người dùng từ BaseScreen
  const UserScreen({super.key, this.user});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  late User? _user;
  late Future<void> _userFuture;

  @override
  void initState() {
    super.initState();

    if (widget.user != null) {
      _user = widget.user;
      _userFuture = Future.value(); // Không fetch lại
      print("User passed from BaseScreen: $_user"); // Debug print
    } else {
      final database = FirebaseDatabase.instanceFor(app: Firebase.app());
      final userController = UserController(database);

      _userFuture = userController.fetchCurrentUserData().then((user) {
        print("Fetched user data: $user"); // Debug print
        setState(() {
          _user = user;
        });
      }).catchError((e) {
        print("Error fetching user data: $e"); // Debug print
      });
    }
  }

  void _showEditUserDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'avatar': avatarController.text.trim(),
                };

                if (passwordController.text.trim().isNotEmpty) {
                  updatedData['password'] = passwordController.text.trim();
                }

                try {
                  final database = FirebaseDatabase.instanceFor(app: Firebase.app());
                  final userController = UserController(database);

                  // Cập nhật thông tin người dùng và lấy lại thông tin người dùng mới
                  final updatedUser = await userController.updateUser(user.id, updatedData);

                  if (updatedUser != null) {
                    setState(() {
                      _user = updatedUser; // Cập nhật _user với dữ liệu mới
                    });
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cập nhật thông tin thành công!')),
                  );
                } catch (e) {
                  Navigator.pop(context);
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
    final themeMode = ref.watch(themeProvider);  // Lấy themeMode từ Riverpod
    return Scaffold(
      backgroundColor:  themeMode == ThemeMode.dark ? Colors.black : Colors.white,  // Thay đổi nền theo theme
      body: FutureBuilder<void>(
        future: _userFuture,
        builder: (context, snapshot) {
          print("FutureBuilder state: ${snapshot.connectionState}"); // Debug print
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("FutureBuilder error: ${snapshot.error}"); // Debug print
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (_user == null) {
            print("No user data available"); // Debug print
            return const Center(child: Text('No user data available.'));
          }

          print("Displaying user data: $_user"); // Debug print
          return _buildUserContent(_user!);
        },
      ),
    );
  }

  Widget _buildUserContent(User user) {
    return ListView(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(height: 35),
        userTile(user),
        divider(),
        colorTiles(user),
        divider(),
        bwTitles(context),
      ],
    );
  }

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
        colorTile(Icons.person_outline, Colors.deepPurple,
            "Chỉnh sửa thông tin",
            onTap: () => _showEditUserDialog(context, user)),
        colorTile(Icons.settings_outlined, Colors.blue, "Cài đặt", onTap: () => _showSettingsDialog(context)),
        colorTile(Icons.bookmark_border, Colors.pink, "Sách yêu thích", onTap: () => onSavedArticlesTap(context)),
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
    return colorTile(icon, Colors.black, text,
        blackAndWhite: true, onTap: onTap);
  }

  Widget colorTile(IconData icon, Color color, String text,
      {bool blackAndWhite = false, void Function()? onTap}) {
    return ListTile(
      leading: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color:
              blackAndWhite ? const Color(0xfff3f4fe) : color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: color),
      ),
      title: Txt(
        text: text,
        fontWeight: FontWeight.w500,
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
      onTap: onTap,
    );
  }

  Widget Txt({required String text, FontWeight? fontWeight}) {
    return Text(
      text,
      style: TextStyle(fontWeight: fontWeight ?? FontWeight.normal),
    );
  }

  void logout(BuildContext context) {
    final userController =
        UserController(FirebaseDatabase.instanceFor(app: Firebase.app()));
    userController.logout(context);
  }
  void onSavedArticlesTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedBooksScreen()),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cài đặt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thêm checkbox cho Theme tối
              CheckboxListTile(
                title: const Text('Nền đen chữ trắng'),
                value: ref.watch(themeProvider) == ThemeMode.dark,  // Kiểm tra theme hiện tại
                onChanged: (bool? value) {
                  if (value == true) {
                    ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
                  }
                },
              ),
              // Thêm checkbox cho Theme sáng
              CheckboxListTile(
                title: const Text('Nền trắng chữ đen'),
                value: ref.watch(themeProvider) == ThemeMode.light,  // Kiểm tra theme hiện tại
                onChanged: (bool? value) {
                  if (value == true) {
                    ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }




}
