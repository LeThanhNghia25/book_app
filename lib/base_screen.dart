import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/chapter_screen.dart';
import 'screens/read_screen.dart';
import 'screens/user_screen.dart';
import 'widgets/footer.dart';
import 'widgets/header.dart';
import 'screen/login_screen.dart';
import 'screen/register_sreen.dart';
import 'screens/load_screen.dart';

class BaseScreen extends StatefulWidget {
  final int selectedIndex;

  const BaseScreen({super.key, this.selectedIndex = 0});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChapterScreen(),
    const ReadScreen(),
    const UserScreen(),
    SplashScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _checkLoginStatus();
  }

  // Kiểm tra trạng thái đăng nhập khi mở ứng dụng
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      _isLoggedIn = isLoggedIn;
    });

    if (!_isLoggedIn) {
      // Nếu chưa đăng nhập, điều hướng đến màn hình đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen(email: '', password: '',)),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderWithSearch(),  // Thêm header vào đây
      body: _isLoggedIn
          ? IndexedStack(
        index: _currentIndex,
        children: _screens,
      )
          : const Center(child: CircularProgressIndicator()),  // Hiển thị loading nếu chưa đăng nhập
      bottomNavigationBar: _isLoggedIn
          ? Footer(
        selectedIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      )
          : null,  // Ẩn Footer khi chưa đăng nhập
    );
  }
}
