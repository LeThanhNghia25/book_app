import 'package:book_app/screen/user_screen.dart';
import 'package:flutter/material.dart';
import '../screen/chapter_screen.dart';
import '../screen/read_screen.dart';
import '../screen/user_screen.dart';

Widget buildFooter(BuildContext context) {
  return BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Trang chủ',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Tôi',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.menu_book),
        label: 'Thể Loại',
      ),
    ],
    onTap: (index) {
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/');
          break;
        case 1:
          Navigator.pushNamed(context, '/user');
          break;
        case 2:
          Navigator.pushNamed(context, '/chapters');
          break;
      }
    },
  );
}


