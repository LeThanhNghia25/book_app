import 'package:book_app/screens/admin/admin_screen.dart';
import 'package:book_app/screens/book_details_screen.dart';
import 'package:book_app/screens/category_screen.dart';
import 'package:book_app/screens/home_screen.dart';
import 'package:book_app/screens/user_screen.dart';
import 'package:book_app/widgets/footer.dart';
import 'package:book_app/widgets/header.dart';
import 'package:flutter/material.dart';


import 'models/user.dart';

class BaseScreen extends StatefulWidget {
  final int selectedIndex;
  final User? user;  // Thêm tham số user để truyền dữ liệu người dùng

  const BaseScreen({super.key, this.selectedIndex = 0, this.user});



  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(),
    const AdminScreen(),
    const UserScreen(),  // Sử dụng UserScreen để hiển thị thông tin người dùng

  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderWithSearch(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens.map((screen) {
          // Truyền dữ liệu user vào các màn hình con nếu có
          // if (screen is HomeScreen) {
          //   return HomeScreen(user: widget.user);  // Truyền user vào HomeScreen
          // }
          if (screen is UserScreen) {
            return UserScreen(user: widget.user);  // Truyền user vào UserScreen
          }
          return screen;
        }).toList(),
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
