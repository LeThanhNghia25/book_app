import 'package:book_app/screens/admin/admin_screen.dart';
import 'package:book_app/screens/chat_bot_screen.dart';
import 'package:book_app/widgets/icon_chat_bot.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/user_screen.dart';
import 'screens/category_screen.dart';
import 'widgets/footer.dart';
import 'widgets/header.dart';

class BaseScreen extends StatefulWidget {
  final int selectedIndex;

  const BaseScreen({super.key, this.selectedIndex = 0});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(),
    const AdminScreen(),
    const UserScreen(),
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
      appBar: const HeaderWithSearch(), // Header cố định
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(width: 2.0, color: Colors.black12),
                right: BorderSide(width: 2.0, color: Colors.black12),
              ),
            ),
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          // Icon Chatbot Floating
          FloatingChatbotIcon(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
