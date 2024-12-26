import 'package:flutter/material.dart';

class Footer extends StatefulWidget {
  final int selectedIndex;

  const Footer({super.key, required this.selectedIndex});

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tôi'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Thể Loại'),
      ],
      onTap: (index) {
        if (index == widget.selectedIndex) return;
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
}
