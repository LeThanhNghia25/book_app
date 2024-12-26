import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const Footer({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Thể Loại',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Đọc sách',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Tôi',
        ),
      ],
      selectedItemColor: Colors.red,   // Màu icon được chọn
      unselectedItemColor: Colors.grey,       // Màu icon không được chọn
      backgroundColor: Colors.white,          // Nền của thanh điều hướng
      type: BottomNavigationBarType.fixed,    // Giữ cố định icon, không co giãn
      onTap: onItemTapped,
    );
  }
}
