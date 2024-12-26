import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/chapter_screen.dart';
import 'screens/read_screen.dart';
import 'screens/user_screen.dart';
import 'widgets/footer.dart';

class BaseScreen extends StatefulWidget {
  final int selectedIndex;

  const BaseScreen({super.key, this.selectedIndex = 0});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ChapterScreen(),
    ReadScreen(),
    UserScreen(),
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
